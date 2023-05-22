import { Options } from "$fresh/plugins/twind.ts";
import typography from "https://esm.sh/@twind/typography@0.0.2";

export default {
  plugins: {
    ...typography(),
  },
  selfURL: import.meta.url,
} as Options;
