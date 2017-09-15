-- PC-3264
-- page 95 reorganize fields
insert into konfigurasjon.page_fieldproperty values ('956a7f1a-d589-4422-b9af-a23ff3ac41be', '335321c9-58d7-4aba-85fc-f208e963fee1', '45fca5ff-c819-4745-8ffe-668ea1cf852e', 5, 'PowerCatch Update Script', now(), 0); -- PC_PROJECT_NUMBER
update konfigurasjon.page_fieldproperty set sortorder = 3, changed_by = 'PowerCatch Update Script', changed_date = now() where id_page = '335321c9-58d7-4aba-85fc-f208e963fee1' and id_fieldproperty = '2c44e699-173c-4091-9a5c-873e459618a3'; --PC_PLANNED_DATE
update konfigurasjon.page_fieldproperty set sortorder = 4, changed_by = 'PowerCatch Update Script', changed_date = now() where id_page = '335321c9-58d7-4aba-85fc-f208e963fee1' and id_fieldproperty = '549ab99d-d4a4-4454-a418-deb6d3423f8b'; -- duedate
update konfigurasjon.page_fieldproperty set sortorder = 6, changed_by = 'PowerCatch Update Script', changed_date = now() where id_page = '335321c9-58d7-4aba-85fc-f208e963fee1' and id_fieldproperty = '250b1d86-34fd-47ff-a9b6-de5aec805e3e'; -- PC_SAFETY_LEADER_WORK_RESPONSIBLE

-- page 105 reorganize fields
insert into konfigurasjon.page_fieldproperty values ('7be8179b-ec17-4ab5-9ef2-6cc0af2bba6f', '7dbb5114-e884-3645-daee-ee421bbf4a8b', '45fca5ff-c819-4745-8ffe-668ea1cf852e', 5, 'PowerCatch Update Script', now(), 0); -- PC_PROJECT_NUMBER
update konfigurasjon.page_fieldproperty set sortorder = 3, changed_by = 'PowerCatch Update Script', changed_date = now() where id_page = '7dbb5114-e884-3645-daee-ee421bbf4a8b' and id_fieldproperty = '2c44e699-173c-4091-9a5c-873e459618a3'; --PC_PLANNED_DATE
update konfigurasjon.page_fieldproperty set sortorder = 4, changed_by = 'PowerCatch Update Script', changed_date = now() where id_page = '7dbb5114-e884-3645-daee-ee421bbf4a8b' and id_fieldproperty = '549ab99d-d4a4-4454-a418-deb6d3423f8b'; -- duedate
update konfigurasjon.page_fieldproperty set sortorder = 6, changed_by = 'PowerCatch Update Script', changed_date = now() where id_page = '7dbb5114-e884-3645-daee-ee421bbf4a8b' and id_fieldproperty = '250b1d86-34fd-47ff-a9b6-de5aec805e3e'; -- PC_SAFETY_LEADER_WORK_RESPONSIBLE