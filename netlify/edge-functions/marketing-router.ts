const GA_MEASUREMENT_ID = "G-TL50DGZ82K";

export function rewriteAnalyticsForConsent(html: string) {
  const googleLoader = new RegExp(
    `<script\\b[^>]*\\bsrc=["']https:\\/\\/www\\.googletagmanager\\.com\\/gtag\\/js\\?id=${GA_MEASUREMENT_ID}(?:&[^"']*)?["'][^>]*>\\s*<\\/script\\s*>`,
    "gi",
  );
  const googleConfig = new RegExp(
    `<script\\b[^>]*>(?:(?!<\\/script\\s*>)[\\s\\S])*?gtag\\s*\\(\\s*["']config["']\\s*,\\s*["']${GA_MEASUREMENT_ID}["'][\\s\\S]*?<\\/script\\s*>`,
    "gi",
  );
  const plausibleLoader = /<script\b[^>]*\bsrc=["'][^"']*plausible\.io\/js\/[^"']*["'][^>]*>\s*<\/script\s*>/gi;

  const withoutGoogleLoader = html.replace(googleLoader, "");
  const withoutGoogleConfig = withoutGoogleLoader.replace(googleConfig, "");
  const rewritten = withoutGoogleConfig.replace(plausibleLoader, "");
  return {
    html: rewritten,
    removedGoogleLoaderCount: (html.match(googleLoader) || []).length,
    removedGoogleConfigCount: (withoutGoogleLoader.match(googleConfig) || []).length,
    removedPlausibleLoaderCount: (withoutGoogleConfig.match(plausibleLoader) || []).length,
  };
}

export function injectAnalyticsConsent(html: string) {
  const consentLoader = '<script defer src="/assets/analytics-consent.js"></script>';
  const withConsent = html.includes('/assets/analytics-consent.js')
    ? html
    : html.includes('</head>')
    ? html.replace('</head>', `${consentLoader}</head>`)
    : `${consentLoader}${html}`;
  return withConsent;
}

export function injectKlaviyoOnsite(html: string) {
  const klaviyoKey = "UQCDKa";
  const klaviyoUrl = `https://static.klaviyo.com/onsite/js/${klaviyoKey}/klaviyo.js?company_id=${klaviyoKey}`;
  const gateMarker = "data-bc-klaviyo-consent-gate";
  if (html.includes(gateMarker)) return html;

  // Keep signup forms available while suppressing optional Klaviyo tracking
  // until this browser has explicitly granted the site's analytics choice.
  // If suppression cannot be verified, fail closed and leave Klaviyo unloaded.
  const trackingGate = `<script ${gateMarker}>(function(){
    var granted=false;
    try{granted=window.localStorage.getItem("bc_analytics_consent_v1")==="granted";}catch(_){granted=false;}
    var suppressionVerified=false;
    try{
      document.cookie=granted?"__kla_off=; Max-Age=0; Path=/; SameSite=Lax":"__kla_off=true; Path=/; SameSite=Lax";
      suppressionVerified=document.cookie.split(";").some(function(cookie){return cookie.trim()==="__kla_off=true";});
    }catch(_){suppressionVerified=false;}
    if(!granted&&!suppressionVerified)return;
    if(!window.klaviyo){window._klOnsite=window._klOnsite||[];try{window.klaviyo=new Proxy({},{get:function(target,property){return"push"===property?function(){var queue;(queue=window._klOnsite).push.apply(queue,arguments)}:function(){for(var length=arguments.length,args=new Array(length),index=0;index<arguments.length;index++)args[index]=arguments[index];var callback="function"==typeof args[args.length-1]?args.pop():void 0,promise=new Promise(function(resolve){window._klOnsite.push([property].concat(args,[function(result){if(callback)callback(result);resolve(result)}]))});return promise}}})}catch(error){window.klaviyo=window.klaviyo||[],window.klaviyo.push=function(){var queue;(queue=window._klOnsite).push.apply(queue,arguments)}}}
    var script=document.createElement("script");script.async=true;script.type="text/javascript";script.src="${klaviyoUrl}";script.setAttribute("data-bc-klaviyo","onsite");document.head.appendChild(script);
  })();</script>`;
  return html.includes("</head>") ? html.replace("</head>", `${trackingGate}</head>`) : `${trackingGate}${html}`;
}

export default async (request: Request, context: { next: () => Promise<Response> }) => {
  const response = await context.next();
  const type = response.headers.get("content-type") || "";
  if (!type.includes("text/html")) return response;
  const { html: consentSafeHtml } = rewriteAnalyticsForConsent(await response.text());
  const injectedHtml = injectAnalyticsConsent(consentSafeHtml);
  const html = injectKlaviyoOnsite(injectedHtml);
  const headers = new Headers(response.headers);
  headers.delete("content-length");
  return new Response(html, { status: response.status, statusText: response.statusText, headers });
};
