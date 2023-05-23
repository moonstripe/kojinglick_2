import { Options } from "$fresh/plugins/twind.ts";
import typography from "https://esm.sh/@twind/typography@0.0.2";

export default {
  plugins: {
    ...typography(),
  },
  theme: {
    extend: {
      colors: {
        "neutral": "#bbb"
      }
    }
  },
  selfURL: import.meta.url,
} as Options;
