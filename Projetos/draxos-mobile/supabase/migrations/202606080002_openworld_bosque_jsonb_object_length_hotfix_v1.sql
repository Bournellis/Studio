-- Bosque Persistence Rebase v1 remote runtime hotfix.
-- Supabase's current Postgres runtime does not expose jsonb_object_length(jsonb).
-- Historical Openworld checkpoint functions already reference that helper name,
-- so provide a narrow public shim instead of rewriting applied migrations.

create or replace function public.jsonb_object_length(p_value jsonb)
returns integer
language sql
immutable
as $$
	select case
		when jsonb_typeof(coalesce(p_value, '{}'::jsonb)) = 'object' then (
			select count(*)::integer
			from jsonb_object_keys(coalesce(p_value, '{}'::jsonb))
		)
		else 0
	end;
$$;

revoke all on function public.jsonb_object_length(jsonb) from public, anon, authenticated;
grant execute on function public.jsonb_object_length(jsonb) to service_role;

comment on function public.jsonb_object_length(jsonb) is
	'Compatibility shim for Openworld checkpoint SQL on Supabase runtimes without a native jsonb_object_length(jsonb).';

notify pgrst, 'reload schema';
