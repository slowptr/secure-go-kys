package com.slowptr.securegokys;

import de.robv.android.xposed.IXposedHookLoadPackage;
import de.robv.android.xposed.XC_MethodHook;
import de.robv.android.xposed.XposedBridge;
import de.robv.android.xposed.XposedHelpers;
import de.robv.android.xposed.callbacks.XC_LoadPackage;

public class Mod implements IXposedHookLoadPackage {
    private static final String TAG = "SecureGoKys";
    private static final String TARGET_PACKAGE = "de.fiduciagad.securego.vr";

    @Override
    public void handleLoadPackage(final XC_LoadPackage.LoadPackageParam lpparam) {
        if (!TARGET_PACKAGE.equals(lpparam.packageName)) return;

        hook("zvp.ag.a(Application)", new HookAction() {
            @Override
            public void run() throws Throwable {
                Class<?> applicationClass = Class.forName("zvp.ae", false, lpparam.classLoader);
                XposedHelpers.findAndHookMethod("zvp.ag", lpparam.classLoader, "a",
                    applicationClass, returnNull());
            }
        });

        hook("vt8.a", new HookAction() {
            @Override
            public void run() {
                XposedHelpers.findAndHookMethod("vt8", lpparam.classLoader, "a",
                    String.class, returnNull());
            }
        });

        hook("MainActivity.exitApp", new HookAction() {
            @Override
            public void run() {
                XposedHelpers.findAndHookMethod("de.fiduciagad.securego.MainActivity",
                    lpparam.classLoader, "exitApp", returnNull());
            }
        });

        hook("zvp.aj.b", new HookAction() {
            @Override
            public void run() {
                XposedHelpers.findAndHookMethod("zvp.aj", lpparam.classLoader, "b",
                    String.class, returnNull());
            }
        });
    }

    private static XC_MethodHook returnNull() {
        return new XC_MethodHook() {
            @Override
            protected void beforeHookedMethod(MethodHookParam param) {
                param.setResult(null);
            }
        };
    }

    private static void hook(String name, HookAction action) {
        try {
            action.run();
            XposedBridge.log(TAG + ": hooked " + name);
        } catch (Throwable error) {
            XposedBridge.log(TAG + ": failed to hook " + name);
            XposedBridge.log(error);
        }
    }

    private interface HookAction {
        void run() throws Throwable;
    }
}
