// Netlify trigger: runs automatically after each VERIFIED Netlify form submission.
// This function is deliberately fail-closed and form-scoped: unrelated Netlify
// forms must never be sent to the Bible Copilot subscriber list.
// Docs: https://docs.netlify.com/build/functions/trigger-on-events/

const COMPANY_ID = "UQCDKa";        // Klaviyo public API key (safe to expose)
const LIST_ID = "XUbnq5";           // Klaviyo list: "Bible Copilot Leads"
const FORM_NAME = "verse-of-the-day";
const PREFERENCES_FORM_NAME = "daily-study-preferences";
const ALLOWED_GOALS = new Set(["understand_scripture", "build_habit", "prepare_group", "hard_questions"]);
const ALLOWED_CADENCE = new Set(["daily", "weekdays"]);
const ALLOWED_DEPTH = new Set(["brief", "deeper"]);

function submissionFormName(payload, data) {
  return payload.form_name || payload.formName || data["form-name"] || data.form_name || "";
}

export async function handler(event) {
  try {
    const body = JSON.parse(event.body || "{}");
    const payload = body.payload || {};
    const data = payload.data || {};
    const formName = submissionFormName(payload, data);
    if (formName !== FORM_NAME && formName !== PREFERENCES_FORM_NAME) {
      console.info("Bible Copilot subscriber handoff skipped for non-target form", { formName: formName || "missing" });
      return { statusCode: 204, body: "not the verse-of-the-day form" };
    }

    const email = payload.email || data.email;
    const firstName = data.first_name || data.firstname || data.name;
    if (!email) throw new Error("Verified verse-of-the-day submission is missing an email address");

    const properties = {
      bc_signup_surface: "netlify_verse_of_the_day",
      bc_intent: data.intent || "daily_scripture",
      bc_first_source: data.first_source || "direct",
      bc_first_campaign: data.first_campaign || "organic_site",
      bc_signup_page: data.signup_page || "unknown"
    };
    if (formName === PREFERENCES_FORM_NAME) {
      if (!ALLOWED_GOALS.has(data.study_goal) || !ALLOWED_CADENCE.has(data.study_cadence) || !ALLOWED_DEPTH.has(data.study_depth)) {
        throw new Error("Daily-study preferences are incomplete or invalid");
      }
      properties.bc_study_goal = data.study_goal;
      properties.bc_study_cadence = data.study_cadence;
      properties.bc_study_depth = data.study_depth;
      properties.bc_preferences_updated_at = new Date().toISOString();
      properties.bc_signup_surface = "daily_study_preferences";
    }
    const attributes = { email, properties };
    if (firstName) attributes.first_name = firstName;

    const resp = await fetch(
      `https://a.klaviyo.com/client/subscriptions/?company_id=${COMPANY_ID}`,
      {
        method: "POST",
        headers: { "Content-Type": "application/json", revision: "2024-10-15" },
        body: JSON.stringify({
          data: {
            type: "subscription",
            attributes: {
              profile: { data: { type: "profile", attributes } },
            },
            relationships: { list: { data: { type: "list", id: LIST_ID } } },
          },
        }),
      }
    );
    if (!resp.ok) {
      const responseBody = await resp.text();
      throw new Error(`Klaviyo subscription failed (${resp.status}): ${responseBody.slice(0, 500)}`);
    }

    console.info("Bible Copilot subscriber handed off to Klaviyo", { formName, status: resp.status });
    return { statusCode: 202, body: `klaviyo ${resp.status}` };
  } catch (e) {
    console.error("Bible Copilot Klaviyo handoff failed", e);
    return { statusCode: 500, body: `error ${e.message}` };
  }
}
