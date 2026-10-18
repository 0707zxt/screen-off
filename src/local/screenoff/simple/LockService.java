package local.screenoff.simple;

import android.accessibilityservice.AccessibilityService;
import android.view.accessibility.AccessibilityEvent;

public final class LockService extends AccessibilityService {
    private static LockService instance;

    @Override protected void onServiceConnected() { instance = this; }
    @Override public void onDestroy() {
        if (instance == this) instance = null;
        super.onDestroy();
    }
    @Override public boolean onUnbind(android.content.Intent intent) {
        if (instance == this) instance = null;
        return super.onUnbind(intent);
    }
    @Override public void onAccessibilityEvent(AccessibilityEvent event) { }
    @Override public void onInterrupt() { }

    static boolean lock() {
        LockService service = instance;
        return service != null && service.performGlobalAction(GLOBAL_ACTION_LOCK_SCREEN);
    }
}
