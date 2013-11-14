Date::DATE_FORMATS[:date_only] = '%Y-%m-%d'
Date::DATE_FORMATS[:with_time] = '%Y-%m-%d %k:%M'
Time::DATE_FORMATS[:with_time] = '%Y-%m-%d %k:%M'
Date::DATE_FORMATS[:with_seconds] = '%Y-%m-%d %k:%M:%S'
Time::DATE_FORMATS[:with_seconds] = '%Y-%m-%d %k:%M:%S'
Time::DATE_FORMATS[:ordinal_date] = lambda { |time| time.strftime("%B #{time.day.ordinalize} %Y") }
Time::DATE_FORMATS[:long_date] = lambda { |time| DateTime.parse(time.to_s).strftime("%F %T %:z") }
Time::DATE_FORMATS[:w3c] = lambda { |time| DateTime.parse(time.to_s).strftime("%FT%T%:z") }