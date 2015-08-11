def create_roles
  Role.delete_all

  Role.create!(:name => "Administrator")
  Role.create!(:name => "Institutional User")
  Role.create!(:name => "API Uploader")
  Role.create!(:name => "Non-Institutional User")
end

def create_tags
  Tag.delete_all

  APP_CONFIG['tags'].each do |hash|
    Tag.create!(hash)
  end
end


def create_parameter_categories
  ParameterCategory.delete_all
  ParameterSubCategory.delete_all
  ParameterModification.delete_all
  ParameterUnit.delete_all

  APP_CONFIG['parameter_categories'].each do |hash|
    sub_categories = hash.delete('sub_categories')
    pc = ParameterCategory.create!(hash)
    sub_categories.each do |psc|
      pc.parameter_sub_categories.create!(psc)
    end
  end

  APP_CONFIG['parameter_units'].each do |hash|
    ParameterUnit.create!(hash)
  end

  APP_CONFIG['parameter_modifications'].each do |hash|
    ParameterModification.create!(hash)
  end
end

def create_sequences
  ActiveRecord::Base.establish_connection(Rails.env.to_sym)
  result = ActiveRecord::Base.connection.execute "SELECT * FROM information_schema.sequences WHERE sequence_schema = 'public' AND sequence_name = 'package_id_seq';"
  ActiveRecord::Base.connection.execute "CREATE SEQUENCE package_id_seq;" if result.count == 0
end

# Inserts languages from ISO 639-1 Language Codes list
# See http://www.w3schools.com/tags/ref_language_codes.asp
def seed_languages
  puts '*** SEEDING THE DATABASE WITH LANGUAGES ***'

  puts 'Removing old languages'
  Language.delete_all

  puts 'Adding languages'
  languages = [{:language_name => 'Abkhazian',   :iso_code => 'ab'},
               {:language_name => 'Afar',   :iso_code => 'aa'},
               {:language_name => 'Afrikaans',   :iso_code => 'af'},
               {:language_name => 'Albanian',   :iso_code => 'sq'},
               {:language_name => 'Amharic',   :iso_code => 'am'},
               {:language_name => 'Arabic',   :iso_code => 'ar'},
               {:language_name => 'Aragonese',   :iso_code => 'an'},
               {:language_name => 'Armenian',   :iso_code => 'hy'},
               {:language_name => 'Assamese',   :iso_code => 'as'},
               {:language_name => 'Aymara',   :iso_code => 'ay'},
               {:language_name => 'Azerbaijani',   :iso_code => 'az'},
               {:language_name => 'Bashkir',   :iso_code => 'ba'},
               {:language_name => 'Basque',   :iso_code => 'eu'},
               {:language_name => 'Bengali (Bangla)',   :iso_code => 'bn'},
               {:language_name => 'Bhutani',   :iso_code => 'dz'},
               {:language_name => 'Bihari',   :iso_code => 'bh'},
               {:language_name => 'Bislama',   :iso_code => 'bi'},
               {:language_name => 'Breton',   :iso_code => 'br'},
               {:language_name => 'Bulgarian',   :iso_code => 'bg'},
               {:language_name => 'Burmese',   :iso_code => 'my'},
               {:language_name => 'Byelorussian (Belarusian)',   :iso_code => 'be'},
               {:language_name => 'Cambodian',   :iso_code => 'km'},
               {:language_name => 'Catalan',   :iso_code => 'ca'},
               {:language_name => 'Cherokee',   :iso_code => nil},
               {:language_name => 'Chewa',   :iso_code => nil},
               {:language_name => 'Chinese',   :iso_code => 'zh'},
               {:language_name => 'Chinese (Simplified)',   :iso_code => 'zh-Hans'},
               {:language_name => 'Chinese (Traditional)',   :iso_code => 'zh-Hant'},
               {:language_name => 'Corsican',   :iso_code => 'co'},
               {:language_name => 'Croatian',   :iso_code => 'hr'},
               {:language_name => 'Czech',   :iso_code => 'cs'},
               {:language_name => 'Danish',   :iso_code => 'da'},
               {:language_name => 'Divehi',   :iso_code => nil},
               {:language_name => 'Dutch',   :iso_code => 'nl'},
               {:language_name => 'Edo',   :iso_code => nil},
               {:language_name => 'English',   :iso_code => 'en'},
               {:language_name => 'Esperanto',   :iso_code => 'eo'},
               {:language_name => 'Estonian',   :iso_code => 'et'},
               {:language_name => 'Faeroese',   :iso_code => 'fo'},
               {:language_name => 'Farsi',   :iso_code => 'fa'},
               {:language_name => 'Fiji',   :iso_code => 'fj'},
               {:language_name => 'Finnish',   :iso_code => 'fi'},
               {:language_name => 'Flemish',   :iso_code => nil},
               {:language_name => 'French',   :iso_code => 'fr'},
               {:language_name => 'Frisian',   :iso_code => 'fy'},
               {:language_name => 'Fulfulde',   :iso_code => nil},
               {:language_name => 'Galician',   :iso_code => 'gl'},
               {:language_name => 'Gaelic (Scottish)',   :iso_code => 'gd'},
               {:language_name => 'Gaelic (Manx)',   :iso_code => 'gv'},
               {:language_name => 'Georgian',   :iso_code => 'ka'},
               {:language_name => 'German',   :iso_code => 'de'},
               {:language_name => 'Greek',   :iso_code => 'el'},
               {:language_name => 'Greenlandic',   :iso_code => 'kl'},
               {:language_name => 'Guarani',   :iso_code => 'gn'},
               {:language_name => 'Gujarati',   :iso_code => 'gu'},
               {:language_name => 'Haitian Creole',   :iso_code => 'ht'},
               {:language_name => 'Hausa',   :iso_code => 'ha'},
               {:language_name => 'Hawaiian',   :iso_code => nil},
               {:language_name => 'Hebrew',   :iso_code => 'he, iw'},
               {:language_name => 'Hindi',   :iso_code => 'hi'},
               {:language_name => 'Hungarian',   :iso_code => 'hu'},
               {:language_name => 'Ibibio',   :iso_code => nil},
               {:language_name => 'Icelandic',   :iso_code => 'is'},
               {:language_name => 'Ido',   :iso_code => 'io'},
               {:language_name => 'Igbo',   :iso_code => nil},
               {:language_name => 'Indonesian',   :iso_code => 'id, in'},
               {:language_name => 'Interlingua',   :iso_code => 'ia'},
               {:language_name => 'Interlingue',   :iso_code => 'ie'},
               {:language_name => 'Inuktitut',   :iso_code => 'iu'},
               {:language_name => 'Inupiak',   :iso_code => 'ik'},
               {:language_name => 'Irish',   :iso_code => 'ga'},
               {:language_name => 'Italian',   :iso_code => 'it'},
               {:language_name => 'Japanese',   :iso_code => 'ja'},
               {:language_name => 'Javanese',   :iso_code => 'jv'},
               {:language_name => 'Kannada',   :iso_code => 'kn'},
               {:language_name => 'Kanuri',   :iso_code => nil},
               {:language_name => 'Kashmiri',   :iso_code => 'ks'},
               {:language_name => 'Kazakh',   :iso_code => 'kk'},
               {:language_name => 'Kinyarwanda (Ruanda)',   :iso_code => 'rw'},
               {:language_name => 'Kirghiz',   :iso_code => 'ky'},
               {:language_name => 'Kirundi (Rundi)',   :iso_code => 'rn'},
               {:language_name => 'Konkani',   :iso_code => nil},
               {:language_name => 'Korean',   :iso_code => 'ko'},
               {:language_name => 'Kurdish',   :iso_code => 'ku'},
               {:language_name => 'Laothian',   :iso_code => 'lo'},
               {:language_name => 'Latin',   :iso_code => 'la'},
               {:language_name => 'Latvian (Lettish)',   :iso_code => 'lv'},
               {:language_name => 'Limburgish ( Limburger)',   :iso_code => 'li'},
               {:language_name => 'Lingala',   :iso_code => 'ln'},
               {:language_name => 'Lithuanian',   :iso_code => 'lt'},
               {:language_name => 'Macedonian',   :iso_code => 'mk'},
               {:language_name => 'Malagasy',   :iso_code => 'mg'},
               {:language_name => 'Malay',   :iso_code => 'ms'},
               {:language_name => 'Malayalam',   :iso_code => 'ml'},
               {:language_name => 'Maltese',   :iso_code => 'mt'},
               {:language_name => 'Maori',   :iso_code => 'mi'},
               {:language_name => 'Marathi',   :iso_code => 'mr'},
               {:language_name => 'Moldavian',   :iso_code => 'mo'},
               {:language_name => 'Mongolian',   :iso_code => 'mn'},
               {:language_name => 'Nauru',   :iso_code => 'na'},
               {:language_name => 'Nepali',   :iso_code => 'ne'},
               {:language_name => 'Norwegian',   :iso_code => 'no'},
               {:language_name => 'Occitan',   :iso_code => 'oc'},
               {:language_name => 'Oriya',   :iso_code => 'or'},
               {:language_name => 'Oromo (Afaan Oromo)',   :iso_code => 'om'},
               {:language_name => 'Papiamentu',   :iso_code => nil},
               {:language_name => 'Pashto (Pushto)',   :iso_code => 'ps'},
               {:language_name => 'Polish',   :iso_code => 'pl'},
               {:language_name => 'Portuguese',   :iso_code => 'pt'},
               {:language_name => 'Punjabi',   :iso_code => 'pa'},
               {:language_name => 'Quechua',   :iso_code => 'qu'},
               {:language_name => 'Rhaeto-Romance',   :iso_code => 'rm'},
               {:language_name => 'Romanian',   :iso_code => 'ro'},
               {:language_name => 'Russian',   :iso_code => 'ru'},
               {:language_name => 'Sami (Lappish)',   :iso_code => nil},
               {:language_name => 'Samoan',   :iso_code => 'sm'},
               {:language_name => 'Sangro',   :iso_code => 'sg'},
               {:language_name => 'Sanskrit',   :iso_code => 'sa'},
               {:language_name => 'Serbian',   :iso_code => 'sr'},
               {:language_name => 'Serbo-Croatian',   :iso_code => 'sh'},
               {:language_name => 'Sesotho',   :iso_code => 'st'},
               {:language_name => 'Setswana',   :iso_code => 'tn'},
               {:language_name => 'Shona',   :iso_code => 'sn'},
               {:language_name => 'Sichuan Yi',   :iso_code => 'ii'},
               {:language_name => 'Sindhi',   :iso_code => 'sd'},
               {:language_name => 'Sinhalese',   :iso_code => 'si'},
               {:language_name => 'Siswati',   :iso_code => 'ss'},
               {:language_name => 'Slovak',   :iso_code => 'sk'},
               {:language_name => 'Slovenian',   :iso_code => 'sl'},
               {:language_name => 'Somali',   :iso_code => 'so'},
               {:language_name => 'Spanish',   :iso_code => 'es'},
               {:language_name => 'Sundanese',   :iso_code => 'su'},
               {:language_name => 'Swahili (Kiswahili)',   :iso_code => 'sw'},
               {:language_name => 'Swedish',   :iso_code => 'sv'},
               {:language_name => 'Syriac',   :iso_code => nil},
               {:language_name => 'Tagalog',   :iso_code => 'tl'},
               {:language_name => 'Tajik',   :iso_code => 'tg'},
               {:language_name => 'Tamazight',   :iso_code => nil},
               {:language_name => 'Tamil',   :iso_code => 'ta'},
               {:language_name => 'Tatar',   :iso_code => 'tt'},
               {:language_name => 'Telugu',   :iso_code => 'te'},
               {:language_name => 'Thai',   :iso_code => 'th'},
               {:language_name => 'Tibetan',   :iso_code => 'bo'},
               {:language_name => 'Tigrinya',   :iso_code => 'ti'},
               {:language_name => 'Tonga',   :iso_code => 'to'},
               {:language_name => 'Tsonga',   :iso_code => 'ts'},
               {:language_name => 'Turkish',   :iso_code => 'tr'},
               {:language_name => 'Turkmen',   :iso_code => 'tk'},
               {:language_name => 'Twi',   :iso_code => 'tw'},
               {:language_name => 'Uighur',   :iso_code => 'ug'},
               {:language_name => 'Ukrainian',   :iso_code => 'uk'},
               {:language_name => 'Urdu',   :iso_code => 'ur'},
               {:language_name => 'Uzbek',   :iso_code => 'uz'},
               {:language_name => 'Venda',   :iso_code => nil},
               {:language_name => 'Vietnamese',   :iso_code => 'vi'},
               {:language_name => 'Volapük',   :iso_code => 'vo'},
               {:language_name => 'Wallon',   :iso_code => 'wa'},
               {:language_name => 'Welsh',   :iso_code => 'cy'},
               {:language_name => 'Wolof',   :iso_code => 'wo'},
               {:language_name => 'Xhosa',   :iso_code => 'xh'},
               {:language_name => 'Yi',   :iso_code => nil},
               {:language_name => 'Yiddish',   :iso_code => 'yi, ji'},
               {:language_name => 'Yoruba',   :iso_code => 'yo'},
               {:language_name => 'Zulu',   :iso_code => 'zu'},]
  languages.each do |language|
    Language.create(:language_name => language[:language_name], :iso_code => language[:iso_code])
  end

  # Set the default language to English
  SystemConfiguration.instance.update_attribute(:language, Language.find_by_iso_code('en'))
end