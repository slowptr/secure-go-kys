package de.robv.android.xposed;

public class XC_MethodHook {
    public final class Unhook {}

    public static class MethodHookParam {
        public Object thisObject;
        public Object[] args;
        public Object getThisObject() { return thisObject; }
        public Object getResult() { return null; }
        public void setResult(Object result) {}
    }
    protected void beforeHookedMethod(MethodHookParam param) throws Throwable {}
    protected void afterHookedMethod(MethodHookParam param) throws Throwable {}
}
