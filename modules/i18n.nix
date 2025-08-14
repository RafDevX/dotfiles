{ ... }:

{
  # This keeps the system language as US English, but uses European standards
  # for everything else; namely dates, currency, number formatting, paper sizes,
  # and metric units.
  # See: https://unix.stackexchange.com/a/62317
  i18n = {
    defaultLocale = "en_IE.UTF-8";
    extraLocaleSettings = {
      LANGUAGE = "en_US";
    };
  };
}
