// a very simple timer that can be used to trigger events

public class Timer {
    public int duration;
    public int startTime;
    public boolean isActivated;
    public TimerMessage message;

    public Timer() {
        duration = -1;
        startTime = -1;
        isActivated = false;
    }

    public void startTimer(int duration, TimerMessage message) {
        this.duration = duration;
        this.message = message;
        startTime = millis();
        isActivated = true;
    }

    public int update() {
        if (!isActivated) {
            return -1;  // not activated
        }
        
        if (millis() - startTime > duration) {
            isActivated = false;
            return 1;   // timer finished
        } else {
            return 0;   // timer still running
        }
    }

    public void reset() {
        duration = -1;
        startTime = -1;
        isActivated = false;
    }

    public TimerMessage getMessage() {
        return message;
    }

    public boolean getIsActivated() {return isActivated};
}

public class TimerMessage {
    public String[] msgStr;
    public int[] msgInt;
    public float[] msgFloat;
    public Object[] msgObj;

    public TimerMessage(
        String[] msgStr,
        int[] msgInt,
        float[] msgFloat,
        Object[] msgObj
    ) {
        this.msgStr = msgStr;
        this.msgInt = msgInt;
        this.msgFloat = msgFloat;
        this.msgObj = msgObj;
    }
}