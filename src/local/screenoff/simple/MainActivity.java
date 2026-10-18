package local.screenoff.simple;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.Bundle;
import android.provider.Settings;

public final class MainActivity extends Activity {
    @Override public void onCreate(Bundle state) {
        super.onCreate(state);
        if (LockService.lock()) {
            finish();
            return;
        }
        new AlertDialog.Builder(this)
            .setTitle("开启一键息屏")
            .setMessage("首次使用：在系统无障碍设置中找到“一键息屏”，开启服务。\n\n之后点击桌面图标即可息屏。应用不联网，也不读取屏幕内容。\n\n若服务已开启但无法息屏，请关闭服务后重新开启。")
            .setPositiveButton("去开启", (dialog, which) -> {
                try { startActivity(new Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)); }
                catch (android.content.ActivityNotFoundException e) { startActivity(new Intent(Settings.ACTION_SETTINGS)); }
                finish();
            })
            .setNegativeButton("取消", (dialog, which) -> finish())
            .setOnCancelListener(dialog -> finish())
            .show();
    }
}
