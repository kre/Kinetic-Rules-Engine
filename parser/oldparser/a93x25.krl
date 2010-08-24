{"global":[{"source":"http://kpds:$up3rs3cr3t@kpds.kynetx.com/secure/criminal.json","name":"criminal","type":"datasource","datatype":"JSON","cachable":0}],"global_start_line":13,"dispatch":[{"domain":"entity.dnb.com","ruleset_id":null}],"dispatch_start_col":5,"meta_start_line":2,"rules":[{"cond":{"val":"true","type":"bool"},"blocktype":"every","actions":[{"label":null,"emit":"$K(document).ready(function() {\n\t\t\t\t\t    var service_error = false;\n\t\t\t\t\t    if (sr == null || sr.service_error != null) {\n\t\t\t\t\t        service_error = true;\n\t\t\t\t\t    }\n\t\t\t\t\t    $K(\"#ajax-loader\").hide();\n\t\t\t\t\t    if (sr != 'null' && typeof(sr.offenders) != 'undefined' && sr.offenders.length != 0 && !service_error) {\n\t\t\t\t\t        var offenders = sr.offenders;\n\t\t\t\t\t        for (var i = 0; i < offenders.length; i++) {\n\t\t\t\t\t            var record = offenders[i];\n\t\t\t\t\t            var alias_block = \"\";\n\t\t\t\t\t            for (var ii = 0; ii < record.ALIASES.length; ii++) {\n\t\t\t\t\t                var data = convert_to_array_hash(record.ALIASES[ii]);\n\t\t\t\t\t                alias_block = alias_block + generate_single_line(\"Name\", data.ALIAS_NAME);\n\t\t\t\t\t            }\n\t\t\t\t\t            if (!isblank(alias_block))                alias_block = start_wrapper(\"Aliases\") + alias_block + end_wrapper();\n\t\t\t\t\t            var offenses_block = \"\";\n\t\t\t\t\t            for (var ii = 0; ii < record.OFFENSES.length; ii++) {\n\t\t\t\t\t                var data = convert_to_array_hash(record.OFFENSES[ii]);\n\t\t\t\t\t                var temp_result = generate_single_line(\"Offense Type\", data.OFFENSE_TYPE) +\n\t\t\t\t\t                                  generate_single_line(\"Court Clerk Phone\", format_phone(data.COURT_CLERK_PHONE)) +\n\t\t\t\t\t                                  generate_single_line(\"Offense Date\", format_date(data.OFFENSE_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Rebuttal\", data.REBUTTAL) +\n\t\t\t\t\t                                  generate_single_line(\"State Convicted\", data.STATE_CONVICTED) +\n\t\t\t\t\t                                  generate_single_line(\"Case Type\", data.CASE_TYPE) +\n\t\t\t\t\t                                  generate_single_line(\"Offender ID\", data.OFFENDER_ID) +\n\t\t\t\t\t                                  generate_single_line(\"Citation Number\", data.CITATION_NUMBER) +\n\t\t\t\t\t                                  generate_single_line(\"Sub Offense Prefix\", data.SUB_OFFENSE_PREFIX) +\n\t\t\t\t\t                                  generate_single_line(\"Date Filed\", format_date(data.DATE_FILED)) +\n\t\t\t\t\t                                  generate_single_line(\"Offense City\", data.OFFENSE_CITY) +\n\t\t\t\t\t                                  generate_single_line(\"Verdict Finding\", data.VERDICT_FINDING) +\n\t\t\t\t\t                                  generate_single_line(\"Case Category\", data.CASE_CATEGORY) +\n\t\t\t\t\t                                  generate_single_line(\"Disposition\", data.DISPOSITION) +\n\t\t\t\t\t                                  generate_single_line(\"Court Name\", data.COURT_NAME) +\n\t\t\t\t\t                                  generate_single_line(\"Offense ID\", data.OFFENSE_ID) +\n\t\t\t\t\t                                  generate_single_line(\"State Code\", data.STATE_CODE) +\n\t\t\t\t\t                                  generate_single_line(\"Sub Offense Class\", data.SUB_OFFENSE_CLASS) +\n\t\t\t\t\t                                  generate_single_line(\"Offense Code\", data.OFFENSE_CODE) +\n\t\t\t\t\t                                  generate_single_line(\"Offense Class\", data.OFFENSE_CLASS) +\n\t\t\t\t\t                                  generate_single_line(\"Disposition Date\", format_date(data.DISPOSITION_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Offense State\", data.OFFENSE_STATE) +\n\t\t\t\t\t                                  generate_single_line(\"Sub Offense\", data.SUB_OFFENSE) +\n\t\t\t\t\t                                  generate_single_line(\"Source ID\", data.SOURCE_ID) +\n\t\t\t\t\t                                  generate_single_line(\"Offense County\", data.OFFENSE_COUNTY) +\n\t\t\t\t\t                                  generate_single_line(\"Court Code\", data.COURT_CODE) +\n\t\t\t\t\t                                  generate_single_line(\"Offense Prefix\", data.OFFENSE_PREFIX) +\n\t\t\t\t\t                                  generate_single_line(\"Sub Offense Type\", data.SUB_OFFENSE_TYPE) +\n\t\t\t\t\t                                  generate_single_line(\"Court Case Number\", data.COURT_CASE_NUMBER) +\n\t\t\t\t\t                                  generate_single_line(\"Case Year\", data.CASE_YEAR) +\n\t\t\t\t\t                                  generate_single_line(\"New Plea\", data.NEW_PLEA) +\n\t\t\t\t\t                                  generate_single_line(\"Original Plea Date\", format_date(data.ORIGINAL_PLEA_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Plea Withdrawn Date\", format_date(data.PLEA_WITHDRAWN_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Verdict Conviction Date\", format_date(data.VERDICT_CONVICTION_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Original Plea\", data.ORIGINAL_PLEA) +\n\t\t\t\t\t                                  generate_single_line(\"Case Category Code\", data.CASE_CATEGORY_CODE) +\n\t\t\t\t\t                                  generate_single_line(\"Sub Offense Code\", data.SUB_OFFENSE_CODE) +\n\t\t\t\t\t                                  generate_single_line(\"NCIC Code\", data.NCIC_CODE) +\n\t\t\t\t\t                                  generate_single_line(\"Arrest Date\", format_date(data.ARREST_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"County Convicted\", data.COUNTY_CONVICTED) +\n\t\t\t\t\t                                  generate_single_line(\"Arresting Agency\", data.ARRESTING_AGENCY) +\n\t\t\t\t\t                                  generate_single_line(\"Arraignment Date\", format_date(data.ARRAIGNMENT_DATE));\n\t\t\t\t\t                temp_result = start_wrapper(\"Offense : \" + data.OFFENSE) + temp_result + end_wrapper();\n\t\t\t\t\t                offenses_block = offenses_block + temp_result;\n\t\t\t\t\t            }\n\t\t\t\t\t            offenses_block = start_wrapper(\"Offenses\") + offenses_block + end_wrapper();\n\t\t\t\t\t            var sentences_block = \"\";\n\t\t\t\t\t            for (var ii = 0; ii < record.SENTENCES.length; ii++) {\n\t\t\t\t\t                var data = convert_to_array_hash(record.SENTENCES[ii]);\n\t\t\t\t\t                var temp_result = generate_single_line(\"Supervision County\", data.SUPERVISION_COUNTY) +\n\t\t\t\t\t                                  generate_single_line(\"Parole End Date\", format_date(data.PAROLE_END_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Status\", data.SENTENCE_STATUS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Min Months\", data.SENTENCE_MIN_MONTHS) +\n\t\t\t\t\t                                  generate_single_line(\"Parole Max Days\", data.PAROLE_MAX_DAYS) +\n\t\t\t\t\t                                  generate_single_line(\"Admission Date\", format_date(data.ADMISSION_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Case Type\", data.CASE_TYPE) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Min Years\", data.SENTENCE_MIN_YEARS) +\n\t\t\t\t\t                                  generate_single_line(\"Offender ID\", data.OFFENDER_ID) +\n\t\t\t\t\t                                  generate_single_line(\"Suspended Jail Days\", data.SUSPENDED_JAIL_DAYS) +\n\t\t\t\t\t                                  generate_single_line(\"Offense ID\", data.OFFENSE_ID) +\n\t\t\t\t\t                                  generate_single_line(\"State Code\", data.STATE_CODE) +\n\t\t\t\t\t                                  generate_single_line(\"Admission Type\", data.ADMISSION_TYPE) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Min Years\", data.PROBATION_MIN_YEARS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Max Years\", data.SENTENCE_MAX_YEARS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Comments\", data.SENTENCE_COMMENTS2) +\n\t\t\t\t\t                                  generate_single_line(\"Parole Min Months\", data.PAROLE_MIN_MONTHS) +\n\t\t\t\t\t                                  generate_single_line(\"Suspended Jail Years\", data.SUSPENDED_JAIL_YEARS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Min Days\", data.SENTENCE_MIN_DAYS) +\n\t\t\t\t\t                                  generate_single_line(\"Source ID\", data.SOURCE_ID) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Min Days\", data.PROBATION_MIN_DAYS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Begin Date\", format_date(data.SENTENCE_BEGIN_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Agency\", data.PROBATION_AGENCY) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Start Date\", format_date(data.PROBATION_START_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Actual Release Date\", format_date(data.ACTUAL_RELEASE_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Parole Start Date\", format_date(data.PAROLE_START_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Parole Status\", data.PROBATION_PAROLE_STATUS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Type\", data.SENTENCE_TYPE) +\n\t\t\t\t\t                                  generate_single_line(\"Parole Min Days\", data.PAROLE_MIN_DAYS) +\n\t\t\t\t\t                                  generate_single_line(\"Parole Max Years\", data.PAROLE_MAX_YEARS) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Min Months\", data.PROBATION_MIN_MONTHS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Max Months\", data.SENTENCE_MAX_MONTHS) +\n\t\t\t\t\t                                  generate_single_line(\"Maxiumum Release Date\", format_date(data.MAXIMUM_RELEASE_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Provation Follows\", data.PROBATION_FOLLOWS_Y_N) +\n\t\t\t\t\t                                  generate_single_line(\"Scheduled Release Date\", format_date(data.SCHEDULED_RELEASE_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Time Served Months\", data.TIME_SERVED_MONTHS) + generate_single_line(\"Sentence Comments\", data.SENTENCE_COMMENTS1) +\n\t\t\t\t\t                                  generate_single_line(\"Time Served Days\", data.TIME_SERVED_DAYS) +\n\t\t\t\t\t                                  generate_single_line(\"Parole Min Years\", data.PAROLE_MIN_YEARS) +\n\t\t\t\t\t                                  generate_single_line(\"Probation End Date\", format_date(data.PROBATION_END_DATE)) +\n\t\t\t\t\t                                  generate_single_line(\"Suspended Jail Months\", data.SUSPENDED_JAIL_MONTHS) +\n\t\t\t\t\t                                  generate_single_line(\"Time Served Years\", data.TIME_SERVED_YEARS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Details\", data.SENTENCE_DETAILS) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Max Years\", data.PROBATION_MAX_YEARS) +\n\t\t\t\t\t                                  generate_single_line(\"Sentence Max Days\", data.SENTENCE_MAX_DAYS) +\n\t\t\t\t\t                                  generate_single_line(\"Parole Max Months\", data.PAROLE_MAX_MONTHS) +\n\t\t\t\t\t                                  generate_single_line(\"Case Type Code\", data.CASE_TYPE_CODE) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Max Days\", data.PROBATION_MAX_DAYS) +\n\t\t\t\t\t                                  generate_single_line(\"Release Type\", data.RELEASE_TYPE) +\n\t\t\t\t\t                                  generate_single_line(\"Probation Max Months\", data.PROBATION_MAX_MONTHS);\n\t\t\t\t\t                if (!isblank(temp_result))                    temp_result = start_wrapper(\"Sentence\") + temp_result + end_wrapper();\n\t\t\t\t\t                sentences_block = sentences_block + temp_result;\n\t\t\t\t\t            }\n\t\t\t\t\t            if (!isblank(sentences_block))                    sentences_block = start_wrapper(\"Sentences\") + sentences_block + end_wrapper();\n\t\t\t\t\t            var result = generate_header(\"Criminal / Infraction Data for \", record.NAME) +\n\t\t\t\t\t                         start_wrapper(\"General Information\") +\n\t\t\t\t\t                         generate_single_line(\"Inmate Number\", record.INMATE_NUMBER) +\n\t\t\t\t\t                         generate_single_line(\"Last Institution Code\", record.LAST_INSTITUTION_CODE) +\n\t\t\t\t\t                         generate_single_line(\"Last Institution State\", record.LAST_INSTITUTION_STATE) +\n\t\t\t\t\t                         generate_single_line(\"Physical Build\", record.PHYSICAL_BUILD) +\n\t\t\t\t\t                         generate_single_line(\"Phone\", format_phone(record.PHONE)) +\n\t\t\t\t\t                         generate_single_line(\"Drivers License Number\", record.DRIVER_LICENSE_NUMBER) +\n\t\t\t\t\t                         generate_single_line(\"Institution zip\", record.INSTITUTION_ZIP) +\n\t\t\t\t\t                         generate_single_line(\"Race\", record.RACE) +\n\t\t\t\t\t                         generate_single_line(\"Zip\", record.ZIP) +\n\t\t\t\t\t                         generate_single_line(\"State\", record.STATE_CODE) +\n\t\t\t\t\t                         generate_single_line(\"Race Code\", record.RACE_CODE) +\n\t\t\t\t\t                         generate_single_line(\"Released to Zip\", record.RELEASED_TO_ZIP) +\n\t\t\t\t\t                         generate_single_line(\"Source ID\", record.SOURCE_ID) +\n\t\t\t\t\t                         generate_single_line(\"Next Kin Zip\", record.NEXT_KIN_ZIP) +\n\t\t\t\t\t                         generate_single_line(\"Last Institution\", record.LAST_INSTITUTION) +\n\t\t\t\t\t                         generate_single_line(\"Next Kin Name\", record.NEXT_KIN_NAME) +\n\t\t\t\t\t                         generate_single_line(\"Released to State\", record.RELEASED_TO_STATE) +\n\t\t\t\t\t                         generate_single_line(\"Military Service\", record.MILITARY_SERVICE) +\n\t\t\t\t\t                         generate_single_line(\"Gender Code\", record.GENDER_CODE) +\n\t\t\t\t\t                         generate_single_line(\"Other DOB Used\", record.OTHER_DOB_USED) +\n\t\t\t\t\t                         generate_single_line(\"Institution Phone\", format_phone(record.INSTITUTION_PHONE)) +\n\t\t\t\t\t                         generate_single_line(\"State ID Number\", record.STATE_ID_NUMBER) +\n\t\t\t\t\t                         generate_single_line(\"Next Kin City\", record.NEXT_KIN_CITY) +\n\t\t\t\t\t                         generate_single_line(\"Birth State\", record.BIRTH_STATE) +\n\t\t\t\t\t                         generate_single_line(\"Last Institution City\", record.LAST_INSTITUTION_CITY) +\n\t\t\t\t\t                         generate_single_line(\"Last Institution Address\", record.LAST_INSTITUTION_ADDRESS) +\n\t\t\t\t\t                         generate_single_line(\"SSN\", format_ssn(record.SSN)) +\n\t\t\t\t\t                         generate_single_line(\"Next Kin Phone\", format_phone(record.NEXT_KIN_PHONE)) +\n\t\t\t\t\t                         generate_single_line(\"Citizenship\", record.CITIZENSHIP) +\n\t\t\t\t\t                         generate_single_line(\"Institution Code\", record.INSTITUTION_CODE) +\n\t\t\t\t\t                         generate_single_line(\"Birth Country\", record.BIRTH_COUNTRY) +\n\t\t\t\t\t                         generate_single_line(\"Military Branch\", record.MILITARY_BRANCH) +\n\t\t\t\t\t                         generate_single_line(\"Last Name\", record.LAST_NAME) +\n\t\t\t\t\t                         generate_single_line(\"Institution State\", record.INSTITUTION_STATE) +\n\t\t\t\t\t                         generate_single_line(\"Next Kin Type Code\", record.NEXT_KIN_TYPE_CODE) +\n\t\t\t\t\t                         generate_single_line(\"Date of Birth\", format_blocked_date(record.DOB)) +\n\t\t\t\t\t                         generate_single_line(\"Next Kin State\", record.NEXT_KIN_STATE) +\n\t\t\t\t\t                         generate_single_line(\"City\", record.CITY) +\n\t\t\t\t\t                         generate_single_line(\"Offender Status\", record.OFFENDER_STATUS) +\n\t\t\t\t\t                         generate_single_line(\"Institution Address\", record.INSTITUTION_ADDRESS) +\n\t\t\t\t\t                         generate_single_line(\"Other DOB Used Only\", record.OTHER_DOB_USED_ONLY) +\n\t\t\t\t\t                         generate_single_line(\"Middle Name\", record.MIDDLE_NAME) +\n\t\t\t\t\t                         generate_single_line(\"Ethnicity Code\", record.ETHNICITY_CODE) +\n\t\t\t\t\t                         generate_single_line(\"Gender\", record.GENDER) +\n\t\t\t\t\t                         generate_single_line(\"Last Institution Zip\", record.LAST_INSTITUTION_ZIP) +\n\t\t\t\t\t                         generate_single_line(\"Address 1\", record.ADDRESS_1) +\n\t\t\t\t\t                         generate_single_line(\"Address 2\", record.ADDRESS_2) +\n\t\t\t\t\t                         generate_single_line(\"Address 3\", record.ADDRESS_3) +\n\t\t\t\t\t                         generate_single_line(\"Released to City\", record.RELEASED_TO_CITY) +\n\t\t\t\t\t                         generate_single_line(\"Drivers License State Issue\", record.DRIVER_LICENSE_STATE_ISSUE) +\n\t\t\t\t\t                         generate_single_line(\"Weight\", record.WEIGHT) +\n\t\t\t\t\t                         generate_single_line(\"Skin Color\", record.SKIN_COLOR) +\n\t\t\t\t\t                         generate_single_line(\"Photo Name\", record.PHOTONAME) +\n\t\t\t\t\t                         generate_single_line(\"Rebuttal\", record.REBUTTAL) +\n\t\t\t\t\t                         generate_single_line(\"Released To Name\", record.RELEASED_TO_NAME) +\n\t\t\t\t\t                         generate_single_line(\"File Data Date\", format_date(record.FILE_DATA_DATE)) +\n\t\t\t\t\t                         generate_single_line(\"Ethnicity\", record.ETHNICITY) +\n\t\t\t\t\t                         generate_single_line(\"Institution City\", record.INSTITUTION_CITY) +\n\t\t\t\t\t                         generate_single_line(\"FBI Number\", record.FBI_NUMBER) +\n\t\t\t\t\t                         generate_single_line(\"Hair Color\", record.HAIR_COLOR) +\n\t\t\t\t\t                         generate_single_line(\"Institution Details\", record.INSTITUTION_DETAILS) +\n\t\t\t\t\t                         generate_single_line(\"Offender Status Code\", record.OFFENDER_STATUS_CODE) +\n\t\t\t\t\t                         generate_single_line(\"Released to Address\", record.RELEASED_TO_ADDRESS) +\n\t\t\t\t\t                         generate_single_line(\"State\", record.STATE) +\n\t\t\t\t\t                         generate_single_line(\"Source\", record.SOURCE) +\n\t\t\t\t\t                         generate_single_line(\"Military Discharge\", record.MILITARY_DISCHARGE) +\n\t\t\t\t\t                         generate_single_line(\"Offender ID\", record.OFFENDER_ID) +\n\t\t\t\t\t                         generate_single_line(\"Next Kin Address\", record.NEXT_KIN_ADDRESS) +\n\t\t\t\t\t                         generate_single_line(\"Next Kin Type\", record.NEXT_KIN_TYPE) +\n\t\t\t\t\t                         generate_single_line(\"Birth County\", record.BIRTH_COUNTY) +\n\t\t\t\t\t                         generate_single_line(\"Suffix\", record.SUFFIX) +\n\t\t\t\t\t                         generate_single_line(\"Height\", record.HEIGHT) +\n\t\t\t\t\t                         generate_single_line(\"First Name\", record.FIRST_NAME) +\n\t\t\t\t\t                         generate_single_line(\"Institution Name\", record.INSTITUTION_NAME) +\n\t\t\t\t\t                         generate_single_line(\"Military Discharge Date\", format_date(record.MILITARY_DISCHARGE_DATE)) +\n\t\t\t\t\t                         generate_single_line(\"Eye Color\", record.EYE_COLOR) +\n\t\t\t\t\t                         generate_single_line(\"Release Information\", record.RELEASE_INFORMATION) +\n\t\t\t\t\t                         generate_single_line(\"DC Number\", record.DC_NUMBER) +\n\t\t\t\t\t                         end_wrapper() + alias_block + offenses_block + sentences_block;\n\t\t\t\t\t            $K(\"#kynetx-criminal\").append(full_wrap_start() + result + full_wrap_end());\n\t\t\t\t\t        }\n\t\t\t\t\t    } else {\n\t\t\t\t\t        if (!service_error) {\n\t\t\t\t\t            $K(\"#kynetx-criminal\").append(criminalNotFound);\n\t\t\t\t\t        } else {\n\t\t\t\t\t            $K(\"#kynetx-criminal\").append(\"<b>Criminal Search Service is down</b>\");\n\t\t\t\t\t        }\n\t\t\t\t\t    }\n\t\t\t\t\t    $K(\"#kynetx-criminal\").show();\n\t\t\t\t\t});          "}],"post":null,"pre":[{"rhs":{"source":"page","predicate":"var","args":[{"val":"firstname","type":"str"}],"type":"qualified"},"lhs":"first","type":"expr"},{"rhs":{"source":"page","predicate":"var","args":[{"val":"lastname","type":"str"}],"type":"qualified"},"lhs":"last","type":"expr"},{"rhs":{"source":"page","predicate":"var","args":[{"val":"state","type":"str"}],"type":"qualified"},"lhs":"state","type":"expr"},{"rhs":{"source":"page","predicate":"var","args":[{"val":"birthdate","type":"str"}],"type":"qualified"},"lhs":"birthdate","type":"expr"},{"rhs":{"args":[{"val":"first","type":"var"},{"args":[{"val":" ","type":"str"},{"val":"last","type":"var"}],"type":"prim","op":"+"}],"type":"prim","op":"+"},"lhs":"name","type":"expr"},{"rhs":{"source":"datasource","predicate":"criminal","args":[{"val":[{"rhs":{"val":"state","type":"var"},"lhs":"state"},{"rhs":{"val":"name","type":"var"},"lhs":"name"},{"rhs":{"val":"1","type":"str"},"lhs":"dummy"}],"type":"hashraw"}],"type":"qualified"},"lhs":"sr","type":"expr"},{"rhs":{"source":"page","predicate":"var","args":[{"val":"birthmonth","type":"str"}],"type":"qualified"},"lhs":"birthMonth","type":"expr"},{"rhs":{"source":"page","predicate":"var","args":[{"val":"birthyear","type":"str"}],"type":"qualified"},"lhs":"birthYear","type":"expr"},{"rhs":{"source":"page","predicate":"var","args":[{"val":"streetAddress","type":"str"}],"type":"qualified"},"lhs":"streetAddress","type":"expr"},{"rhs":"<p>Criminal records were not found</p>      \n ","lhs":"criminalNotFound","type":"here_doc"}],"name":"get_criminal_report","start_col":5,"emit":null,"state":"active","callbacks":null,"pagetype":{"event_expr":{"pattern":"https://www.entity.dnb.com:8443/Demo/EntityInvestigate/search/databases.*|https://www.entity.dnb.com/Demo/EntityInvestigate/.*","legacy":1,"type":"prim_event","vars":[],"op":"pageview"},"foreach":[]},"start_line":16}],"meta_start_col":5,"meta":{"logging":"on","name":"d&b investigate Crim Demo","meta_start_line":2,"author":"Mike Grace","description":"second part of d&b app     \n","meta_start_col":5},"dispatch_start_line":10,"global_start_col":5,"ruleset_name":"a93x25"}