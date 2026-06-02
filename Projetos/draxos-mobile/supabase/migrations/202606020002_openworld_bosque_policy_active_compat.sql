-- Openworld Bosque policy compatibility hotfix.
-- Some remote V1 databases were created before mode_limit_policies.active existed,
-- while the Bosque V1 start RPC filters on that column.

alter table public.mode_limit_policies
	add column if not exists active boolean not null default true;

update public.mode_limit_policies
set active = (status = 'active')
where active is distinct from (status = 'active');
