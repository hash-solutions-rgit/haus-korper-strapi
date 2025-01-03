export default ({ env }) => [
  "strapi::logger",
  "strapi::errors",
  "strapi::cors",
  "strapi::poweredBy",
  "strapi::query",
  "strapi::body",
  "strapi::session",
  "strapi::favicon",
  "strapi::public",
  {
    name: "strapi::security",
    config: {
      contentSecurityPolicy: {
        useDefaults: true,
        directives: {
          "connect-src": ["'self'", "https:", "http:"],
          "img-src": [
            "'self'",
            "data:",
            "blob:",
            "lh3.googleusercontent.com", // google avatars
            "platform-lookaside.fbsbx.com", // facebook avatars
            "dl.airtable.com", // strapi marketplace,
            "market-assets.strapi.io",
            env("SUPABASE_API_URL"),
          ],
          "media-src": ["'self'", "data:", "blob:", env("SUPABASE_API_URL")],
          upgradeInsecureRequests: null,
        },
      },
    },
  },
];
