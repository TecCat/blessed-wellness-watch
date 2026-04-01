# Privacy Policy

> **WellnessWatch — Mindful Breathing App for Apple Watch**
> Effective Date: [Insert Date]
> Developer: [Developer / Company Name]

---

> ⚠️ **Deployment Note**: This document must be published as a publicly accessible HTML page (e.g., `https://wellnesswatch.app/privacy`) and linked in the "Privacy Policy URL" field in App Store Connect. Apps using HealthKit that lack an accessible privacy policy will be rejected by Apple.

---

## 1. Data We Collect

WellnessWatch ("the App") is committed to protecting your privacy. This policy explains what data we collect, how we use it, and how we protect it.

### 1.1 Health Data (via HealthKit)

With your explicit permission, the App reads the following HealthKit data types:

| Data Type | Purpose | Storage |
|-----------|---------|---------|
| Heart Rate | Calculate real-time stress level; provide personalized guidance | On-device only |
| Heart Rate Variability SDNN (HRV) | Assess autonomic nervous system state; recommend breathing patterns | On-device only |
| Resting Heart Rate | Long-term baseline comparison | On-device only |

**The App does not write any data back to HealthKit.**

### 1.2 Session Records

The App stores the following data locally on your device:

- Session date and time
- Selected breathing pattern
- Completed cycles and duration
- Pre/post heart rate and HRV changes

### 1.3 AI Coaching Service (Optional Feature)

If you choose to enable AI personalized feedback, the following **anonymized** data is sent to our backend server for processing:

- Session summary statistics (heart rate delta, HRV delta, session duration)
- Stress level assessment result
- Total cumulative session count

**We never transmit:** your name, email address, device identifiers (IDFA/IDFV), precise location, photos, contacts, or any other directly personally identifiable information.

---

## 2. How We Use Your Data

We use collected data solely for the following purposes:

1. **Providing core services** — Displaying real-time heart rate, calculating stress levels, and guiding breathing sessions
2. **Personalizing your experience** — Recommending the most suitable breathing pattern based on your biometrics
3. **Progress tracking** — Showing you your health improvement over time
4. **Generating AI feedback** — (When enabled) Using a large language model to produce personalized session recommendations

We do **not** use your data for advertising targeting, user profiling, sale to third parties, or research purposes without your explicit written consent.

---

## 3. Third-Party Services

| Service | Purpose | Data Shared | Privacy Policy |
|---------|---------|-------------|----------------|
| Anthropic Claude API | AI feedback generation | Anonymous session statistics | [anthropic.com/privacy](https://www.anthropic.com/privacy) |
| Apple HealthKit | Health data framework | Heart rate, HRV (on-device only) | [apple.com/privacy](https://www.apple.com/privacy/) |
| Railway / Render (backend hosting) | API server | Anonymous statistics only | Per deployment platform |

**The App does not include any advertising SDKs, analytics trackers (e.g., Firebase Analytics, Mixpanel), or social media SDKs.**

---

## 4. Data Security

- All health data remains on your Apple Watch and iPhone at all times
- Device sync via iCloud (if enabled by you) is protected by Apple's end-to-end encryption
- AI feedback API transmissions use HTTPS / TLS 1.3 encryption
- Our backend servers do not store any personally identifiable information

---

## 5. Your Privacy Rights

You may at any time:

- **Revoke HealthKit access** — Go to iPhone Settings → Privacy & Security → Health → WellnessWatch and toggle off any or all permissions
- **Delete session records** — Use "Clear All Data" in the App's Settings screen
- **Disable AI coaching** — Turn off "AI Personalized Feedback" in Settings; no further data will be sent to our servers

---

## 6. Children's Privacy

This App is not directed to children under the age of 13 and we do not knowingly collect personal information from children. If you believe your child has provided personal information without your authorization, please contact us using the details below.

---

## 7. Health Disclaimer

WellnessWatch is a wellness support tool that provides guided breathing exercises and health data visualization. **This App does not provide medical diagnosis, does not treat any medical condition, and is not a medical device.** All features are intended for general wellness purposes only. Please consult a qualified healthcare professional for any medical or mental health concerns.

---

## 8. Policy Updates

If we make material changes to this Privacy Policy, we will notify you via an in-app notification. Continued use of the App following notification constitutes acceptance of the updated policy.

---

## 9. Contact Us

For privacy-related questions or requests, please contact:

- **Email**: privacy@wellnesswatch.app
- **Website**: https://wellnesswatch.app/privacy

---

*Effective Date: [Insert Date]*
*Version: 1.0*
