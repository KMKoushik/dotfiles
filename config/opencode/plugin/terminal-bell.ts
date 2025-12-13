// @ts-ignore
import type { Plugin } from "@opencode-ai/plugin";

export const TerminalBell: Plugin = async ({
  project,
  client,
  $,
  directory,
  worktree,
}) => {
  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        try {
          await $`afplay /System/Library/Sounds/Glass.aiff`;
        } catch (err) {
          console.warn("Failed to play audible bell:", err);
        }
      }
    },
  };
};
