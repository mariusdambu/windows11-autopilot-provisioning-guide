document.addEventListener("DOMContentLoaded", () => {
  const button = document.querySelector("[data-print]");

  if (button) {
    button.addEventListener("click", () => {
      window.print();
    });
  }

  document.querySelectorAll("pre").forEach((block) => {
    const code = block.querySelector("code");

    if (!code) {
      return;
    }

    const copyButton = document.createElement("button");
    copyButton.type = "button";
    copyButton.className = "copy-button";
    copyButton.textContent = "Copy";
    copyButton.setAttribute("aria-label", "Copy command");

    copyButton.addEventListener("click", async () => {
      const text = code.innerText;
      const copied = await copyText(text);

      copyButton.textContent = copied ? "Copied" : "Copy failed";
      window.setTimeout(() => {
        copyButton.textContent = "Copy";
      }, 1600);
    });

    block.appendChild(copyButton);
  });
});

async function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) {
    try {
      await navigator.clipboard.writeText(text);
      return true;
    } catch {
      return fallbackCopy(text);
    }
  }

  return fallbackCopy(text);
}

function fallbackCopy(text) {
  const textarea = document.createElement("textarea");
  textarea.value = text;
  textarea.setAttribute("readonly", "");
  textarea.style.position = "fixed";
  textarea.style.top = "-9999px";
  document.body.appendChild(textarea);
  textarea.select();

  try {
    return document.execCommand("copy");
  } finally {
    textarea.remove();
  }
}
