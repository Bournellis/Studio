-- DraxosMobile T00-P11 base manager and economy foundation.
-- Base state is server-authoritative; client mutations go through Edge Functions.

create table if not exists public.base_structures (
	player_id uuid not null references public.players(id) on delete cascade,
	structure_id text not null check (
		structure_id in (
			'altar_das_almas',
			'nucleo_energia',
			'pocos_sangue',
			'minas_cristal',
			'estrutura_stats',
			'ossario'
		)
	),
	level integer not null default 0 check (level >= 0 and level <= 40),
	last_collected_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	primary key (player_id, structure_id)
);

create table if not exists public.construction_jobs (
	id uuid primary key default gen_random_uuid(),
	player_id uuid not null references public.players(id) on delete cascade,
	structure_id text not null check (
		structure_id in (
			'altar_das_almas',
			'nucleo_energia',
			'pocos_sangue',
			'minas_cristal',
			'estrutura_stats',
			'ossario'
		)
	),
	target_level integer not null check (target_level >= 1 and target_level <= 40),
	status text not null default 'active' check (status in ('active', 'completed')),
	cost_payload jsonb not null,
	started_at timestamptz not null default now(),
	completes_at timestamptz not null,
	completed_at timestamptz,
	request_id uuid not null,
	created_at timestamptz not null default now(),
	updated_at timestamptz not null default now(),
	unique (player_id, request_id)
);

create unique index if not exists construction_jobs_one_active_per_structure_idx
	on public.construction_jobs (player_id, structure_id)
	where status = 'active';

create index if not exists construction_jobs_player_status_idx
	on public.construction_jobs (player_id, status, completes_at);

alter table public.base_structures enable row level security;
alter table public.construction_jobs enable row level security;

create policy "base_structures_select_own"
	on public.base_structures for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

create policy "construction_jobs_select_own"
	on public.construction_jobs for select
	using (
		player_id in (
			select id from public.players where auth_user_id = auth.uid()
		)
	);

insert into public.base_structures (player_id, structure_id)
select players.id, structure_ids.structure_id
from public.players
cross join (
	values
		('altar_das_almas'),
		('nucleo_energia'),
		('pocos_sangue'),
		('minas_cristal'),
		('estrutura_stats'),
		('ossario')
) as structure_ids(structure_id)
on conflict (player_id, structure_id) do nothing;
