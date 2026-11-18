package app.hydramind.hydramind
import io.flutter.embedding.android.FlutterFragmentActivity
class MainActivity : FlutterFragmentActivity() {
    override fun getInitialRoute(): String? =
        if (intent?.action == "androidx.health.ACTION_SHOW_PERMISSIONS_RATIONALE" || intent?.action == "android.intent.action.VIEW_PERMISSION_USAGE") "/privacy" else super.getInitialRoute()
}
