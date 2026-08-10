(() => {
  const storageKey = "emilia-rose-registry-language";
  const toggle = document.getElementById("language-toggle");

  if (!toggle) return;

  const storedLanguage = () => {
    try {
      const value = window.localStorage.getItem(storageKey);
      return value === "af" ? "af" : "en";
    } catch (_error) {
      return "en";
    }
  };

  const rememberLanguage = (language) => {
    try {
      window.localStorage.setItem(storageKey, language);
    } catch (_error) {
      // The toggle still works when browser storage is unavailable.
    }
  };

  const applyLanguage = (language) => {
    const isAfrikaans = language === "af";

    document.documentElement.lang = language;
    document.querySelectorAll("[data-i18n-en][data-i18n-af]").forEach((element) => {
      element.textContent = isAfrikaans
        ? element.dataset.i18nAf
        : element.dataset.i18nEn;
    });

    document
      .querySelectorAll("[data-i18n-placeholder-en][data-i18n-placeholder-af]")
      .forEach((element) => {
        element.placeholder = isAfrikaans
          ? element.dataset.i18nPlaceholderAf
          : element.dataset.i18nPlaceholderEn;
      });

    document
      .querySelectorAll("[data-i18n-aria-label-en][data-i18n-aria-label-af]")
      .forEach((element) => {
        element.setAttribute(
          "aria-label",
          isAfrikaans
            ? element.dataset.i18nAriaLabelAf
            : element.dataset.i18nAriaLabelEn,
        );
      });

    document.title = isAfrikaans
      ? document.body.dataset.titleAf
      : document.body.dataset.titleEn;
    toggle.setAttribute("aria-pressed", String(isAfrikaans));
    toggle.setAttribute(
      "aria-label",
      isAfrikaans ? "Skakel oor na Engels" : "Switch to Afrikaans",
    );
  };

  let language = storedLanguage();
  applyLanguage(language);

  toggle.addEventListener("click", () => {
    language = language === "en" ? "af" : "en";
    rememberLanguage(language);
    applyLanguage(language);
  });
})();
