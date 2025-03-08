// map generator

public class GameMap {
    private static final int[] MINE_PROBABILITY = {
        0.1, 0.15, 0.2, 0.5
    };  // probability of one block being mine for levels 1-4
    private static final int[] REVEAL_PROBABILITY = {
        0.20, 0.30, 0.30, 0.40
    };  // probability of one block being revealed at begining for levels 1-4
    private static final int[] SAMPLE_PROBABILITY = {
        0.05, 0.10, 0.20, 0.40
    };  // probability of one block being a sample for levels 1-4

    private ArrayList<ArrayList<ArrayList<Integer>>> gMap;
    private int mineTotal;
    private int mineFlagged;
    private int rewardTotal;
    private int rewardClaimed;
    private boolean hasLanded;
    private int level;
    private boolean hasCheated;

    public GameMap (int lvl) {
        gMap = new ArrayList<ArrayList<ArrayList<Integer>>>();
        mineTotal = -1;
        mineFlagged = 0;
        rewardTotal = -1;
        rewardClaimed = 0;
        hasLanded = false;
        level = lvl;

        preGenerateMap();
    }

    public boolean revealBlock(int x, int y) {
        // init map if it is the first block (landing block)
        if (!hasLanded) {
            onLand(x, y);
            return true;
        }

        // check game violation
        if (gMap.get(y).get(x).get(0) == -1)
            return false;

        ArrayList<Transform> ckdList = new ArrayList<Transform>();
        revealRecursive(x, y, ckdList);
        return true;
    }

    // recursively reveal an area
    private void revealRecursive(int x, int y, ArrayList<Transform> checkedList) {
        if (! (x < 9 && x > -1 && y < 9 && y > -1))
            return;

        ArrayList<Integer> block = queryBlock(x, y);

        if (block.get(0) == -1) return;
        gMap.get(y).get(x).set(1, 0);   // reveal self

        if (block.get(0) > 0) { // do not expand if this is not empty
            return;
        }

        Transform thisTrans = new Transform();
        thisTrans.x = x;
        thisTrans.y = y;
        checkedList.add(thisTrans);

        // attempt to extend to all direction
        for (int i=-1;i<2;i++) {
            for (int j=-1;j<2;j++) {
                int nextX = x+j;
                int nextY = y+i;
                boolean approved = true;
                for (Transform ckd : checkedList) {
                    if (ckd.x == nextX && ckd.y == nextY) {
                        approved = false;
                        break;
                    }
                }
                if (approved) {
                    revealRecursive(nextX, nextY, checkedList);
                }
            }
        }
    }

    public void flagBlock(int x, int y) {
        // unflag if already flagged
        if (gMap.get(y).get(x).get(2) == 1) {
            unflagBlock(x, y);
        }
        else {
            gMap.get(y).get(x).set(2, 1);
            mineFlagged ++;
        }
    }

    public void unflagBlock(int x, int y) {
        gMap.get(y).get(x).set(2, 0);
        mineFlagged --;
    }

    public ArrayList<Integer> queryBlock(int x, int y) {
        return gMap.get(y).get(x);
    }

    public boolean neutralizeBlock(int x, int y) {
        if (gMap.get(y).get(x).get(0) == -1) {
            gMap.get(y).get(x).set(0, -2);   // mark as neutralized
            gMap.get(y).get(x).set(1, 0);   // reveal block
            mineTotal --;
            return true;
        }
        return false;
    }

    // on land, the landing block is guarenteed to be safe.
    private void onLand(int x, int y) {
        hasLanded = true;
        mineTotal = 0;
        rewardTotal = 0;

        // ensure landing zone is safe (no mine in 3x3 area)
        for (int i=-1;i<2;i++) {
            for (int j=-1;j<2;j++) {
                if (x+i > -1 && x+i < 9 && y+j > -1 && y+j < 9) {
                    gMap.get(y+j).get(x+i).set(0, 0);  // not mine
                    gMap.get(y+j).get(x+i).set(3, 0);   // no reward
                }
            }
        }

        // post process the map
        for (int i=0; i<9; i++) {
            for (int j=0; j<9; j++) {
                if (gMap.get(i).get(j).get(0) == -1) {
                    // ensure each mine has at least two nearby empty
                    int nearbyEmpty = 0;
                    for (int sI=-1; sI<2; sI++) {
                        for (int sJ=-1; sJ<2; sJ++) {
                            if (i+sI > -1 && i+sI < 9 && j+sJ > -1 && j+sJ < 9 && gMap.get(i+sI).get(j+sJ).get(0) != -1) {
                                nearbyEmpty ++;
                            }
                        }
                    }

                    if (nearbyEmpty < 2) {
                        console.log("mine removed due to no empty block nearby: ", j, i);
                        gMap.get(i).get(j).set(0, 0);
                    } else {
                        // recount the number of mines
                        mineTotal ++;
                    }
                }

                // set some blocks to be revealed (just by themselves)
                if (gMap.get(i).get(j).get(0) != -1 && random(1) < REVEAL_PROBABILITY[level-1]) {
                    gMap.get(i).get(j).set(1, 0);
                }

                // count rewards
                if (gMap.get(i).get(j).get(3) == 1) {
                    rewardTotal ++;
                }
            }
        }
        
        // calculate numbers
        lableNumbers();

        // properly and recursively reveal the 3x3 blocks
        for (int i=-1;i<2;i++) {
            for (int j=-1;j<2;j++) {
                if (x+i > -1 && x+i < 9 && y+j > -1 && y+j < 9) {
                    revealBlock(x+i, y+j);
                }
            }
        }

        console.log("GameMap: map onLand post-generation completed");
    }

    // game map (x, y, c) where c = [type, isHidden, isFlagged, isReward]
    // type: -1 = landmine, 0 = empty, 1+ = numbers
    private void preGenerateMap() {
        // generate mines
        for (int y=0; y<9; y++) {
            ArrayList<ArrayList<Integer>> row = new ArrayList<ArrayList<Integer>>();
            for (int x=0; x<9; x++) {
                ArrayList<Integer> block = new ArrayList<Integer>();
                if (random(1) < MINE_PROBABILITY[level-1]) {    // will it be a mine?
                    block.add(-1);  // set as mine
                    block.add(1);   // set as hidden
                    block.add(0);   // set as unflagged
                    block.add(0);   // set as no reward
                } else {
                    block.add(0);  // set as a placeholder
                    block.add(1);   // set as hidden
                    block.add(0);   // not flagged
                    if (random(1) < SAMPLE_PROBABILITY[level-1]) {    // determine whether is reward
                        block.add(1);
                    } else {
                        block.add(0);
                    }
                }
                row.add(block);
            }
            gMap.add(row);
        }
        console.log("GameMap: map pre-generation completed");
    }

    private void lableNumbers() {
        for (int y=0; y<9; y++) {
            for (int x=0; x<9; x++) {
                if (gMap.get(y).get(x).get(0) == 0) {
                    gMap.get(y).get(x).set(0, countNearByMines(gMap, x, y));
                }
            }
        }
    }

    private int countNearByMines(ArrayList<ArrayList<ArrayList<Integer>>> mp, int x, int y) {
        int cnt = 0;
        for (int i=-1;i<2;i++) {
            for (int j=-1;j<2;j++) {
                if (x+i > -1 && x+i < 9 && y+j > -1 && y+j < 9 && mp.get(y+j).get(x+i).get(0) == -1) {
                    cnt ++;
                }
            }
        }
        return cnt;
    }

    public boolean checkVictoryCondition() {
        if (mineFlagged == mineTotal) {
            // check if all non-mine blocks are revealed
            for (int i=0; i<9; i++) {
                for (int j=0; j<9; j++) {
                    if (gMap.get(i).get(j).get(0) != -1 && gMap.get(i).get(j).get(1) == 1) {
                        return false;
                    }
                }
            }
            return true;
        }
        return false;
    }

    // cheat func for me
    public void useCheat() {
        // flag every mind & reveal every block
        if (!hasLanded) onLand(0,0);

        for (int i=0; i<9; i++) {   // y
            for (int j=0; j<9; j++) {   // x
                if (gMap.get(i).get(j).get(0) == -1) {
                    if (!hasCheated) {
                        flagBlock(j, i);
                    }
                } else if (gMap.get(i).get(j).get(0) > -1) {
                    if (hasCheated) {
                        revealBlock(j,i);
                    }
                }
            }
        }

        hasCheated = true;
    }

    public int getMineTotal() {return mineTotal;}
    public int getMineFlagged() {return mineFlagged;}
    public int getRewardTotal() {return rewardTotal;}
    public int getRewardClaimed() {return rewardClaimed;}
    public int getRewardTotal() {return rewardTotal;}
}