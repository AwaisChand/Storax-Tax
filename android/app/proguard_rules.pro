# Keep Stripe SDK and metadata
-keep class com.stripe.** { *; }
-keepattributes *Annotation*,Signature,InnerClasses,EnclosingMethod

# Keep push provisioning classes if they exist (prevents stripping)
-keep class com.stripe.android.pushProvisioning.** { *; }
-keepclassmembers class com.stripe.android.pushProvisioning.** { *; }

# Reflection-safe (optional)
-keepclassmembers class com.stripe.android.pushProvisioning.** {
    <init>(...);
    *;
}

# Suppress warnings (from missing_rules.txt)
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivity$g
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Args
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter$Error
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningActivityStarter
-dontwarn com.stripe.android.pushProvisioning.PushProvisioningEphemeralKeyProvider

# General Stripe warnings suppress if needed
-dontwarn com.stripe.**
