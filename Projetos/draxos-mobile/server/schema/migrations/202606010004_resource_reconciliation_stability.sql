-- DraxosMobile Foundation Hardening V2 - resource reconciliation RPC stability.
-- Replaces the JSON loop reconciliation with explicit numeric fields so PostgREST
-- can execute the service-role RPC reliably during live RLS smokes.

create or replace function public.resource_reconciliation_report_v1(
	p_game_save_id uuid
)
returns jsonb
language plpgsql
stable
security definer
set search_path = public, auth, extensions
as $$
declare
	save_row public.game_saves%rowtype;
	resource_row public.resources%rowtype;
	ledger_almas numeric := 0;
	ledger_energia numeric := 0;
	ledger_sangue numeric := 0;
	ledger_cristais numeric := 0;
	ledger_ossos numeric := 0;
	ledger_po_osso numeric := 0;
	ledger_diamante numeric := 0;
	current_almas numeric := 0;
	current_energia numeric := 0;
	current_sangue numeric := 0;
	current_cristais numeric := 0;
	current_ossos numeric := 0;
	current_po_osso numeric := 0;
	current_diamante numeric := 0;
	ledger_payload jsonb;
	current_payload jsonb;
	difference jsonb;
	balanced boolean := false;
begin
	if p_game_save_id is null then
		raise exception 'INVALID_GAME_SAVE_ID' using errcode = 'P0001';
	end if;

	select *
	into save_row
	from public.game_saves
	where id = p_game_save_id
		and lifecycle_status = 'active';

	if save_row.id is null then
		raise exception 'GAME_SAVE_NOT_FOUND' using errcode = 'P0001';
	end if;

	select *
	into resource_row
	from public.resources
	where player_id = save_row.legacy_player_id;

	if resource_row.player_id is null then
		raise exception 'RESOURCES_NOT_FOUND' using errcode = 'P0001';
	end if;

	select
		coalesce(sum(public.foundation_jsonb_numeric_v1(coalesce(delta, '{}'::jsonb), 'almas')), 0),
		coalesce(sum(public.foundation_jsonb_numeric_v1(coalesce(delta, '{}'::jsonb), 'energia')), 0),
		coalesce(sum(public.foundation_jsonb_numeric_v1(coalesce(delta, '{}'::jsonb), 'sangue')), 0),
		coalesce(sum(public.foundation_jsonb_numeric_v1(coalesce(delta, '{}'::jsonb), 'cristais')), 0),
		coalesce(sum(public.foundation_jsonb_numeric_v1(coalesce(delta, '{}'::jsonb), 'ossos')), 0),
		coalesce(sum(public.foundation_jsonb_numeric_v1(coalesce(delta, '{}'::jsonb), 'po_osso')), 0),
		coalesce(sum(public.foundation_jsonb_numeric_v1(coalesce(delta, '{}'::jsonb), 'diamante')), 0)
	into
		ledger_almas,
		ledger_energia,
		ledger_sangue,
		ledger_cristais,
		ledger_ossos,
		ledger_po_osso,
		ledger_diamante
	from public.resource_transactions
	where player_id = save_row.legacy_player_id;

	current_almas := coalesce(resource_row.almas, 0);
	current_energia := coalesce(resource_row.energia, 0);
	current_sangue := coalesce(resource_row.sangue, 0);
	current_cristais := coalesce(resource_row.cristais, 0);
	current_ossos := coalesce(resource_row.ossos, 0);
	current_po_osso := coalesce(resource_row.po_osso, 0);
	current_diamante := coalesce(resource_row.diamante, 0);

	ledger_payload := jsonb_build_object(
		'almas', ledger_almas,
		'energia', ledger_energia,
		'sangue', ledger_sangue,
		'cristais', ledger_cristais,
		'ossos', ledger_ossos,
		'po_osso', ledger_po_osso,
		'diamante', ledger_diamante
	);

	current_payload := jsonb_build_object(
		'almas', current_almas,
		'energia', current_energia,
		'sangue', current_sangue,
		'cristais', current_cristais,
		'ossos', current_ossos,
		'po_osso', current_po_osso,
		'diamante', current_diamante
	);

	difference := jsonb_build_object(
		'almas', current_almas - ledger_almas,
		'energia', current_energia - ledger_energia,
		'sangue', current_sangue - ledger_sangue,
		'cristais', current_cristais - ledger_cristais,
		'ossos', current_ossos - ledger_ossos,
		'po_osso', current_po_osso - ledger_po_osso,
		'diamante', current_diamante - ledger_diamante
	);

	balanced := current_almas = ledger_almas
		and current_energia = ledger_energia
		and current_sangue = ledger_sangue
		and current_cristais = ledger_cristais
		and current_ossos = ledger_ossos
		and current_po_osso = ledger_po_osso
		and current_diamante = ledger_diamante;

	return jsonb_build_object(
		'ok', true,
		'schema_version', 'resource_reconciliation_report_v1',
		'game_save_id', save_row.id,
		'account_profile_id', save_row.account_profile_id,
		'legacy_player_id', save_row.legacy_player_id,
		'current_balance', current_payload,
		'ledger_balance', ledger_payload,
		'difference', difference,
		'balanced', balanced
	);
end;
$$;

revoke all on function public.resource_reconciliation_report_v1(uuid) from public, anon, authenticated;
grant execute on function public.resource_reconciliation_report_v1(uuid) to service_role;
