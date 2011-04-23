TIMEZONE_LIST = YAML.load_file("#{Rails.root}/config/timezones.yml")
TZINFO_IDENTIFIERS = []
TZInfo::Timezone.all_identifiers.each_index { |i| TZINFO_IDENTIFIERS[i] = TZInfo::Timezone.all_identifiers[i].downcase }
DATETIME_TRANSLATION = YAML.load_file("#{Rails.root}/config/datetime_translation.yml")

