import { withCorsResponse } from "../_shared/http.ts";
import { modeHandler } from "./mode_handler.ts";

Deno.serve(async (request: Request) => {
  return withCorsResponse(request, await modeHandler(request));
});
