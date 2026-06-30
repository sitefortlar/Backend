--
-- PostgreSQL database dump
--

\restrict c81orbekjIo9jKPJq6RU4yzVAIYHxfkBGLVFlmGASQCq9ah300XB9Ws8tShbk3H

-- Dumped from database version 17.6
-- Dumped by pg_dump version 18.4 (Ubuntu 18.4-1.pgdg24.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA auth;


--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA extensions;


--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql;


--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA graphql_public;


--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA pgbouncer;


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA realtime;


--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA storage;


--
-- Name: vault; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA vault;


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


--
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


--
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


--
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


--
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


--
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


--
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: -
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


--
-- Name: email_token_type_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.email_token_type_enum AS ENUM (
    'VALIDACAO_EMAIL',
    'RESET_SENHA'
);


--
-- Name: perfil_enum; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.perfil_enum AS ENUM (
    'ADMIN',
    'CLIENTE'
);


--
-- Name: action; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: -
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


--
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: -
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: -
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: -
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: -
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: graphql(text, text, jsonb, jsonb); Type: FUNCTION; Schema: graphql_public; Owner: -
--

CREATE FUNCTION graphql_public.graphql("operationName" text DEFAULT NULL::text, query text DEFAULT NULL::text, variables jsonb DEFAULT NULL::jsonb, extensions jsonb DEFAULT NULL::jsonb) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: -
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $_$
begin
    raise debug 'PgBouncer auth request: %', p_usename;

    return query
    select 
        rolname::text, 
        case when rolvaliduntil < now() 
            then null 
            else rolpassword::text 
        end 
    from pg_authid 
    where rolname=$1 and rolcanlogin;
end;
$_$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = now();
   RETURN NEW;
END;
$$;


--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
    -- Regclass of the table e.g. public.notes
    entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

    -- I, U, D, T: insert, update ...
    action realtime.action = (
        case wal ->> 'action'
            when 'I' then 'INSERT'
            when 'U' then 'UPDATE'
            when 'D' then 'DELETE'
            else 'ERROR'
        end
    );

    -- Is row level security enabled for the table
    is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

    subscriptions realtime.subscription[] = array_agg(subs)
        from
            realtime.subscription subs
        where
            subs.entity = entity_
            -- Filter by action early - only get subscriptions interested in this action
            -- action_filter column can be: '*' (all), 'INSERT', 'UPDATE', or 'DELETE'
            and (subs.action_filter = '*' or subs.action_filter = action::text);

    -- Subscription vars
    working_role regrole;
    working_selected_columns text[];
    claimed_role regrole;
    claims jsonb;

    subscription_id uuid;
    subscription_has_access bool;
    visible_to_subscription_ids uuid[] = '{}';

    -- structured info for wal's columns
    columns realtime.wal_column[];
    -- previous identity values for update/delete
    old_columns realtime.wal_column[];

    error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

    -- Primary jsonb output for record
    output jsonb;

    -- Loop record for iterating unique roles (outer loop)
    role_record record;
    -- Loop record for iterating unique selected_columns within a role (inner loop)
    cols_record record;
    -- Subscription ids visible at the role level (before fanning out by selected_columns)
    visible_role_sub_ids uuid[] = '{}';

begin
    perform set_config('role', null, true);

    columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'columns') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    old_columns =
        array_agg(
            (
                x->>'name',
                x->>'type',
                x->>'typeoid',
                realtime.cast(
                    (x->'value') #>> '{}',
                    coalesce(
                        (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                        (x->>'type')::regtype
                    )
                ),
                (pks ->> 'name') is not null,
                true
            )::realtime.wal_column
        )
        from
            jsonb_array_elements(wal -> 'identity') x
            left join jsonb_array_elements(wal -> 'pk') pks
                on (x ->> 'name') = (pks ->> 'name');

    for role_record in
        select claims_role
        from (select distinct claims_role from unnest(subscriptions)) t
        order by claims_role::text
    loop
        working_role := role_record.claims_role;

        -- Update `is_selectable` for columns and old_columns (once per role)
        columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(columns) c;

        old_columns =
                array_agg(
                    (
                        c.name,
                        c.type_name,
                        c.type_oid,
                        c.value,
                        c.is_pkey,
                        pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                    )::realtime.wal_column
                )
                from
                    unnest(old_columns) c;

        if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
            -- Fan out 400 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 400: Bad Request, no primary key']
                )::realtime.wal_rls;
            end loop;

        -- The claims role does not have SELECT permission to the primary key of entity
        elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
            -- Fan out 401 error per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;
                return next (
                    jsonb_build_object(
                        'schema', wal ->> 'schema',
                        'table', wal ->> 'table',
                        'type', action
                    ),
                    is_rls_enabled,
                    (select array_agg(s.subscription_id) from unnest(subscriptions) as s where s.claims_role = working_role and (s.selected_columns is not distinct from working_selected_columns)),
                    array['Error 401: Unauthorized']
                )::realtime.wal_rls;
            end loop;

        else
            -- Create the prepared statement (once per role)
            if is_rls_enabled and action <> 'DELETE' then
                if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                    deallocate walrus_rls_stmt;
                end if;
                execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
            end if;

            -- Collect all visible subscription IDs for this role (filter check + RLS check)
            visible_role_sub_ids = '{}';

            for subscription_id, claims in (
                    select
                        subs.subscription_id,
                        subs.claims
                    from
                        unnest(subscriptions) subs
                    where
                        subs.entity = entity_
                        and subs.claims_role = working_role
                        and (
                            realtime.is_visible_through_filters(columns, subs.filters)
                            or (
                              action = 'DELETE'
                              and realtime.is_visible_through_filters(old_columns, subs.filters)
                            )
                        )
            ) loop

                if not is_rls_enabled or action = 'DELETE' then
                    visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                else
                    -- Check if RLS allows the role to see the record
                    perform
                        -- Trim leading and trailing quotes from working_role because set_config
                        -- doesn't recognize the role as valid if they are included
                        set_config('role', trim(both '"' from working_role::text), true),
                        set_config('request.jwt.claims', claims::text, true);

                    execute 'execute walrus_rls_stmt' into subscription_has_access;

                    if subscription_has_access then
                        visible_role_sub_ids = visible_role_sub_ids || subscription_id;
                    end if;
                end if;
            end loop;

            perform set_config('role', null, true);

            -- Inner loop: per distinct selected_columns for this role
            for cols_record in
                select selected_columns
                from (select distinct selected_columns from unnest(subscriptions) s where s.claims_role = working_role) t
                order by coalesce(array_to_string(selected_columns, ','), '')
            loop
                working_selected_columns := cols_record.selected_columns;

                output = jsonb_build_object(
                    'schema', wal ->> 'schema',
                    'table', wal ->> 'table',
                    'type', action,
                    'commit_timestamp', to_char(
                        ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                        'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
                    ),
                    'columns', (
                        select
                            jsonb_agg(
                                jsonb_build_object(
                                    'name', pa.attname,
                                    'type', pt.typname
                                )
                                order by pa.attnum asc
                            )
                        from
                            pg_attribute pa
                            join pg_type pt
                                on pa.atttypid = pt.oid
                            left join (
                                select unnest(conkey) as pkey_attnum
                                from pg_constraint
                                where conrelid = entity_ and contype = 'p'
                            ) pk on pk.pkey_attnum = pa.attnum
                        where
                            attrelid = entity_
                            and attnum > 0
                            and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                            and (working_selected_columns is null or pa.attname = any(working_selected_columns) or pk.pkey_attnum is not null)
                    )
                )
                -- Add "record" key for insert and update
                || case
                    when action in ('INSERT', 'UPDATE') then
                        jsonb_build_object(
                            'record',
                            (
                                select
                                    jsonb_object_agg(
                                        -- if unchanged toast, get column name and value from old record
                                        coalesce((c).name, (oc).name),
                                        case
                                            when (c).name is null then (oc).value
                                            else (c).value
                                        end
                                    )
                                from
                                    unnest(columns) c
                                    full outer join unnest(old_columns) oc
                                        on (c).name = (oc).name
                                where
                                    coalesce((c).is_selectable, (oc).is_selectable)
                                    and (working_selected_columns is null or coalesce((c).name, (oc).name) = any(working_selected_columns) or coalesce((c).is_pkey, (oc).is_pkey))
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            )
                        )
                    else '{}'::jsonb
                end
                -- Add "old_record" key for update and delete
                || case
                    when action = 'UPDATE' then
                        jsonb_build_object(
                                'old_record',
                                (
                                    select jsonb_object_agg((c).name, (c).value)
                                    from unnest(old_columns) c
                                    where
                                        (c).is_selectable
                                        and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                        and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                )
                            )
                    when action = 'DELETE' then
                        jsonb_build_object(
                            'old_record',
                            (
                                select jsonb_object_agg((c).name, (c).value)
                                from unnest(old_columns) c
                                where
                                    (c).is_selectable
                                    and (working_selected_columns is null or (c).name = any(working_selected_columns) or (c).is_pkey)
                                    and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                                    and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                            )
                        )
                    else '{}'::jsonb
                end;

                -- Filter visible_role_sub_ids to those matching the current selected_columns group
                visible_to_subscription_ids = coalesce(
                    (
                        select array_agg(s.subscription_id)
                        from unnest(subscriptions) s
                        where s.claims_role = working_role
                          and (s.selected_columns is not distinct from working_selected_columns)
                          and s.subscription_id = any(visible_role_sub_ids)
                    ),
                    '{}'::uuid[]
                );

                return next (
                    output,
                    is_rls_enabled,
                    visible_to_subscription_ids,
                    case
                        when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                        else '{}'
                    end
                )::realtime.wal_rls;
            end loop;

        end if;
    end loop;

    perform set_config('role', null, true);
end;
$$;


--
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
declare
  res jsonb;
begin
  if type_::text = 'bytea' then
    return to_jsonb(val);
  end if;
  execute format('select to_jsonb(%L::'|| type_::text || ')', val) into res;
  return res;
end
$$;


--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


--
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS TABLE(wal jsonb, is_rls_enabled boolean, subscription_ids uuid[], errors text[], slot_changes_count bigint)
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
  WITH pub AS (
    SELECT
      concat_ws(
        ',',
        CASE WHEN bool_or(pubinsert) THEN 'insert' ELSE NULL END,
        CASE WHEN bool_or(pubupdate) THEN 'update' ELSE NULL END,
        CASE WHEN bool_or(pubdelete) THEN 'delete' ELSE NULL END
      ) AS w2j_actions,
      coalesce(
        string_agg(
          realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
          ','
        ) filter (WHERE ppt.tablename IS NOT NULL),
        ''
      ) AS w2j_add_tables
    FROM pg_publication pp
    LEFT JOIN pg_publication_tables ppt ON pp.pubname = ppt.pubname
    WHERE pp.pubname = publication
    GROUP BY pp.pubname
    LIMIT 1
  ),
  -- MATERIALIZED ensures pg_logical_slot_get_changes is called exactly once
  w2j AS MATERIALIZED (
    SELECT x.*, pub.w2j_add_tables
    FROM pub,
         pg_logical_slot_get_changes(
           slot_name, null, max_changes,
           'include-pk', 'true',
           'include-transaction', 'false',
           'include-timestamp', 'true',
           'include-type-oids', 'true',
           'format-version', '2',
           'actions', pub.w2j_actions,
           'add-tables', pub.w2j_add_tables
         ) x
  ),
  slot_count AS (
    SELECT count(*)::bigint AS cnt
    FROM w2j
    WHERE w2j.w2j_add_tables <> ''
  ),
  rls_filtered AS (
    SELECT xyz.wal, xyz.is_rls_enabled, xyz.subscription_ids, xyz.errors
    FROM w2j,
         realtime.apply_rls(
           wal := w2j.data::jsonb,
           max_record_bytes := max_record_bytes
         ) xyz(wal, is_rls_enabled, subscription_ids, errors)
    WHERE w2j.w2j_add_tables <> ''
      AND xyz.subscription_ids[1] IS NOT NULL
  )
  SELECT rf.wal, rf.is_rls_enabled, rf.subscription_ids, rf.errors, sc.cnt
  FROM rls_filtered rf, slot_count sc

  UNION ALL

  SELECT null, null, null, null, sc.cnt
  FROM slot_count sc
  WHERE NOT EXISTS (SELECT 1 FROM rls_filtered)
$$;


--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  SELECT
    realtime.wal2json_escape_identifier(nsp.nspname::text)
    || '.'
    || realtime.wal2json_escape_identifier(pc.relname::text)
  FROM pg_class pc
  JOIN pg_namespace nsp ON pc.relnamespace = nsp.oid
  WHERE pc.oid = entity
$$;


--
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: send_binary(bytea, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.send_binary(payload bytea, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
BEGIN
  BEGIN
    generated_id := gen_random_uuid();

    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    INSERT INTO realtime.messages (id, binary_payload, event, topic, private, extension)
    VALUES (generated_id, payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      RAISE WARNING 'WarnSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
declare
    col_names text[] = coalesce(
            array_agg(a.attname order by a.attnum),
            '{}'::text[]
        )
        from
            pg_catalog.pg_attribute a
        where
            a.attrelid = new.entity
            and a.attnum > 0
            and not a.attisdropped
            and pg_catalog.has_column_privilege(
                (new.claims ->> 'role'),
                a.attrelid,
                a.attnum,
                'SELECT'
            );
    filter realtime.user_defined_filter;
    col_type regtype;
    in_val jsonb;
    selected_col text;
begin
    for filter in select * from unnest(new.filters) loop
        if not filter.column_name = any(col_names) then
            raise exception 'invalid column for filter %', filter.column_name;
        end if;

        col_type = (
            select atttypid::regtype
            from pg_catalog.pg_attribute
            where attrelid = new.entity
                  and attname = filter.column_name
        );
        if col_type is null then
            raise exception 'failed to lookup type for column %', filter.column_name;
        end if;

        if filter.op = 'in'::realtime.equality_op then
            in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
            if coalesce(jsonb_array_length(in_val), 0) > 100 then
                raise exception 'too many values for `in` filter. Maximum 100';
            end if;
        else
            perform realtime.cast(filter.value, col_type);
        end if;
    end loop;

    if new.selected_columns is not null then
        for selected_col in select * from unnest(new.selected_columns) loop
            if not selected_col = any(col_names) then
                raise exception 'invalid column for select %', selected_col;
            end if;
        end loop;
    end if;

    new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value),
        '{}'
    ) from unnest(new.filters) f;

    new.selected_columns = (
        select array_agg(c order by c)
        from unnest(new.selected_columns) c
    );

    return new;
end;
$$;


--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


--
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


--
-- Name: wal2json_escape_identifier(text); Type: FUNCTION; Schema: realtime; Owner: -
--

CREATE FUNCTION realtime.wal2json_escape_identifier(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
  -- Prefix `\`, `,`, `.`, and any whitespace with `\`
  SELECT regexp_replace(name, '([\\,.[:space:]])', '\\\1', 'g')
$$;


--
-- Name: allow_any_operation(text[]); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_any_operation(expected_operations text[]) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT CASE
      WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
      ELSE raw_operation
    END AS current_operation
    FROM current_operation
  )
  SELECT EXISTS (
    SELECT 1
    FROM normalized n
    CROSS JOIN LATERAL unnest(expected_operations) AS expected_operation
    WHERE expected_operation IS NOT NULL
      AND expected_operation <> ''
      AND n.current_operation = CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END
  );
$$;


--
-- Name: allow_only_operation(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.allow_only_operation(expected_operation text) RETURNS boolean
    LANGUAGE sql STABLE
    AS $$
  WITH current_operation AS (
    SELECT storage.operation() AS raw_operation
  ),
  normalized AS (
    SELECT
      CASE
        WHEN raw_operation LIKE 'storage.%' THEN substr(raw_operation, 9)
        ELSE raw_operation
      END AS current_operation,
      CASE
        WHEN expected_operation LIKE 'storage.%' THEN substr(expected_operation, 9)
        ELSE expected_operation
      END AS requested_operation
    FROM current_operation
  )
  SELECT CASE
    WHEN requested_operation IS NULL OR requested_operation = '' THEN FALSE
    ELSE COALESCE(current_operation = requested_operation, FALSE)
  END
  FROM normalized;
$$;


--
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


--
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Get the last path segment (the actual filename)
    SELECT _parts[array_length(_parts, 1)] INTO _filename;
    -- Extract extension: reverse, split on '.', then reverse again
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


--
-- Name: get_common_prefix(text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_common_prefix(p_key text, p_prefix text, p_delimiter text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
SELECT CASE
    WHEN position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)) > 0
    THEN left(p_key, length(p_prefix) + position(p_delimiter IN substring(p_key FROM length(p_prefix) + 1)))
    ELSE NULL
END;
$$;


--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint)::bigint as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


--
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


--
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.list_objects_with_delimiter(_bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;

    -- Configuration
    v_is_asc BOOLEAN;
    v_prefix TEXT;
    v_start TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_is_asc := lower(coalesce(sort_order, 'asc')) = 'asc';
    v_prefix := coalesce(prefix_param, '');
    v_start := CASE WHEN coalesce(next_token, '') <> '' THEN next_token ELSE coalesce(start_after, '') END;
    v_file_batch_size := LEAST(GREATEST(max_keys * 2, 100), 1000);

    -- Calculate upper bound for prefix filtering (bytewise, using COLLATE "C")
    IF v_prefix = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix, 1) = delimiter_param THEN
        v_upper_bound := left(v_prefix, -1) || chr(ascii(delimiter_param) + 1);
    ELSE
        v_upper_bound := left(v_prefix, -1) || chr(ascii(right(v_prefix, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'AND o.name COLLATE "C" < $3 ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" >= $2 ' ||
                'ORDER BY o.name COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'AND o.name COLLATE "C" >= $3 ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND o.name COLLATE "C" < $2 ' ||
                'ORDER BY o.name COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- ========================================================================
    -- SEEK INITIALIZATION: Determine starting position
    -- ========================================================================
    IF v_start = '' THEN
        IF v_is_asc THEN
            v_next_seek := v_prefix;
        ELSE
            -- DESC without cursor: find the last item in range
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_next_seek FROM storage.objects o
                WHERE o.bucket_id = _bucket_id
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;

            IF v_next_seek IS NOT NULL THEN
                v_next_seek := v_next_seek || delimiter_param;
            ELSE
                RETURN;
            END IF;
        END IF;
    ELSE
        -- Cursor provided: determine if it refers to a folder or leaf
        IF EXISTS (
            SELECT 1 FROM storage.objects o
            WHERE o.bucket_id = _bucket_id
              AND o.name COLLATE "C" LIKE v_start || delimiter_param || '%'
            LIMIT 1
        ) THEN
            -- Cursor refers to a folder
            IF v_is_asc THEN
                v_next_seek := v_start || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_start || delimiter_param;
            END IF;
        ELSE
            -- Cursor refers to a leaf object
            IF v_is_asc THEN
                v_next_seek := v_start || delimiter_param;
            ELSE
                v_next_seek := v_start;
            END IF;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= max_keys;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek AND o.name COLLATE "C" < v_upper_bound
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" >= v_next_seek
                ORDER BY o.name COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek AND o.name COLLATE "C" >= v_prefix
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = _bucket_id AND o.name COLLATE "C" < v_next_seek
                ORDER BY o.name COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(v_peek_name, v_prefix, delimiter_param);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Emit and skip to next folder (no heap access needed)
            name := rtrim(v_common_prefix, delimiter_param);
            id := NULL;
            updated_at := NULL;
            created_at := NULL;
            last_accessed_at := NULL;
            metadata := NULL;
            RETURN NEXT;
            v_count := v_count + 1;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := left(v_common_prefix, -1) || chr(ascii(delimiter_param) + 1);
            ELSE
                v_next_seek := v_common_prefix;
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query USING _bucket_id, v_next_seek,
                CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix) ELSE v_prefix END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(v_current.name, v_prefix, delimiter_param);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := v_current.name;
                    EXIT;
                END IF;

                -- Emit file
                name := v_current.name;
                id := v_current.id;
                updated_at := v_current.updated_at;
                created_at := v_current.created_at;
                last_accessed_at := v_current.last_accessed_at;
                metadata := v_current.metadata;
                RETURN NEXT;
                v_count := v_count + 1;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := v_current.name || delimiter_param;
                ELSE
                    v_next_seek := v_current.name;
                END IF;

                EXIT WHEN v_count >= max_keys;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


--
-- Name: protect_delete(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.protect_delete() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if storage.allow_delete_query is set to 'true'
    IF COALESCE(current_setting('storage.allow_delete_query', true), 'false') != 'true' THEN
        RAISE EXCEPTION 'Direct deletion from storage tables is not allowed. Use the Storage API instead.'
            USING HINT = 'This prevents accidental data loss from orphaned objects.',
                  ERRCODE = '42501';
    END IF;
    RETURN NULL;
END;
$$;


--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_peek_name TEXT;
    v_current RECORD;
    v_common_prefix TEXT;
    v_delimiter CONSTANT TEXT := '/';

    -- Configuration
    v_limit INT;
    v_prefix TEXT;
    v_prefix_lower TEXT;
    v_is_asc BOOLEAN;
    v_order_by TEXT;
    v_sort_order TEXT;
    v_upper_bound TEXT;
    v_file_batch_size INT;

    -- Dynamic SQL for batch query only
    v_batch_query TEXT;

    -- Seek state
    v_next_seek TEXT;
    v_count INT := 0;
    v_skipped INT := 0;
BEGIN
    -- ========================================================================
    -- INITIALIZATION
    -- ========================================================================
    v_limit := LEAST(coalesce(limits, 100), 1500);
    v_prefix := coalesce(prefix, '') || coalesce(search, '');
    v_prefix_lower := lower(v_prefix);
    v_is_asc := lower(coalesce(sortorder, 'asc')) = 'asc';
    v_file_batch_size := LEAST(GREATEST(v_limit * 2, 100), 1000);

    -- Validate sort column
    CASE lower(coalesce(sortcolumn, 'name'))
        WHEN 'name' THEN v_order_by := 'name';
        WHEN 'updated_at' THEN v_order_by := 'updated_at';
        WHEN 'created_at' THEN v_order_by := 'created_at';
        WHEN 'last_accessed_at' THEN v_order_by := 'last_accessed_at';
        ELSE v_order_by := 'name';
    END CASE;

    v_sort_order := CASE WHEN v_is_asc THEN 'asc' ELSE 'desc' END;

    -- ========================================================================
    -- NON-NAME SORTING: Use path_tokens approach (unchanged)
    -- ========================================================================
    IF v_order_by != 'name' THEN
        RETURN QUERY EXECUTE format(
            $sql$
            WITH folders AS (
                SELECT path_tokens[$1] AS folder
                FROM storage.objects
                WHERE objects.name ILIKE $2 || '%%'
                  AND bucket_id = $3
                  AND array_length(objects.path_tokens, 1) <> $1
                GROUP BY folder
                ORDER BY folder %s
            )
            (SELECT folder AS "name",
                   NULL::uuid AS id,
                   NULL::timestamptz AS updated_at,
                   NULL::timestamptz AS created_at,
                   NULL::timestamptz AS last_accessed_at,
                   NULL::jsonb AS metadata FROM folders)
            UNION ALL
            (SELECT path_tokens[$1] AS "name",
                   id, updated_at, created_at, last_accessed_at, metadata
             FROM storage.objects
             WHERE objects.name ILIKE $2 || '%%'
               AND bucket_id = $3
               AND array_length(objects.path_tokens, 1) = $1
             ORDER BY %I %s)
            LIMIT $4 OFFSET $5
            $sql$, v_sort_order, v_order_by, v_sort_order
        ) USING levels, v_prefix, bucketname, v_limit, offsets;
        RETURN;
    END IF;

    -- ========================================================================
    -- NAME SORTING: Hybrid skip-scan with batch optimization
    -- ========================================================================

    -- Calculate upper bound for prefix filtering
    IF v_prefix_lower = '' THEN
        v_upper_bound := NULL;
    ELSIF right(v_prefix_lower, 1) = v_delimiter THEN
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(v_delimiter) + 1);
    ELSE
        v_upper_bound := left(v_prefix_lower, -1) || chr(ascii(right(v_prefix_lower, 1)) + 1);
    END IF;

    -- Build batch query (dynamic SQL - called infrequently, amortized over many rows)
    IF v_is_asc THEN
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'AND lower(o.name) COLLATE "C" < $3 ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" >= $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" ASC LIMIT $4';
        END IF;
    ELSE
        IF v_upper_bound IS NOT NULL THEN
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'AND lower(o.name) COLLATE "C" >= $3 ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        ELSE
            v_batch_query := 'SELECT o.name, o.id, o.updated_at, o.created_at, o.last_accessed_at, o.metadata ' ||
                'FROM storage.objects o WHERE o.bucket_id = $1 AND lower(o.name) COLLATE "C" < $2 ' ||
                'ORDER BY lower(o.name) COLLATE "C" DESC LIMIT $4';
        END IF;
    END IF;

    -- Initialize seek position
    IF v_is_asc THEN
        v_next_seek := v_prefix_lower;
    ELSE
        -- DESC: find the last item in range first (static SQL)
        IF v_upper_bound IS NOT NULL THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower AND lower(o.name) COLLATE "C" < v_upper_bound
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSIF v_prefix_lower <> '' THEN
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_prefix_lower
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        ELSE
            SELECT o.name INTO v_peek_name FROM storage.objects o
            WHERE o.bucket_id = bucketname
            ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
        END IF;

        IF v_peek_name IS NOT NULL THEN
            v_next_seek := lower(v_peek_name) || v_delimiter;
        ELSE
            RETURN;
        END IF;
    END IF;

    -- ========================================================================
    -- MAIN LOOP: Hybrid peek-then-batch algorithm
    -- Uses STATIC SQL for peek (hot path) and DYNAMIC SQL for batch
    -- ========================================================================
    LOOP
        EXIT WHEN v_count >= v_limit;

        -- STEP 1: PEEK using STATIC SQL (plan cached, very fast)
        IF v_is_asc THEN
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek AND lower(o.name) COLLATE "C" < v_upper_bound
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" >= v_next_seek
                ORDER BY lower(o.name) COLLATE "C" ASC LIMIT 1;
            END IF;
        ELSE
            IF v_upper_bound IS NOT NULL THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSIF v_prefix_lower <> '' THEN
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek AND lower(o.name) COLLATE "C" >= v_prefix_lower
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            ELSE
                SELECT o.name INTO v_peek_name FROM storage.objects o
                WHERE o.bucket_id = bucketname AND lower(o.name) COLLATE "C" < v_next_seek
                ORDER BY lower(o.name) COLLATE "C" DESC LIMIT 1;
            END IF;
        END IF;

        EXIT WHEN v_peek_name IS NULL;

        -- STEP 2: Check if this is a FOLDER or FILE
        v_common_prefix := storage.get_common_prefix(lower(v_peek_name), v_prefix_lower, v_delimiter);

        IF v_common_prefix IS NOT NULL THEN
            -- FOLDER: Handle offset, emit if needed, skip to next folder
            IF v_skipped < offsets THEN
                v_skipped := v_skipped + 1;
            ELSE
                name := split_part(rtrim(storage.get_common_prefix(v_peek_name, v_prefix, v_delimiter), v_delimiter), v_delimiter, levels);
                id := NULL;
                updated_at := NULL;
                created_at := NULL;
                last_accessed_at := NULL;
                metadata := NULL;
                RETURN NEXT;
                v_count := v_count + 1;
            END IF;

            -- Advance seek past the folder range
            IF v_is_asc THEN
                v_next_seek := lower(left(v_common_prefix, -1)) || chr(ascii(v_delimiter) + 1);
            ELSE
                v_next_seek := lower(v_common_prefix);
            END IF;
        ELSE
            -- FILE: Batch fetch using DYNAMIC SQL (overhead amortized over many rows)
            -- For ASC: upper_bound is the exclusive upper limit (< condition)
            -- For DESC: prefix_lower is the inclusive lower limit (>= condition)
            FOR v_current IN EXECUTE v_batch_query
                USING bucketname, v_next_seek,
                    CASE WHEN v_is_asc THEN COALESCE(v_upper_bound, v_prefix_lower) ELSE v_prefix_lower END, v_file_batch_size
            LOOP
                v_common_prefix := storage.get_common_prefix(lower(v_current.name), v_prefix_lower, v_delimiter);

                IF v_common_prefix IS NOT NULL THEN
                    -- Hit a folder: exit batch, let peek handle it
                    v_next_seek := lower(v_current.name);
                    EXIT;
                END IF;

                -- Handle offset skipping
                IF v_skipped < offsets THEN
                    v_skipped := v_skipped + 1;
                ELSE
                    -- Emit file
                    name := split_part(v_current.name, v_delimiter, levels);
                    id := v_current.id;
                    updated_at := v_current.updated_at;
                    created_at := v_current.created_at;
                    last_accessed_at := v_current.last_accessed_at;
                    metadata := v_current.metadata;
                    RETURN NEXT;
                    v_count := v_count + 1;
                END IF;

                -- Advance seek past this file
                IF v_is_asc THEN
                    v_next_seek := lower(v_current.name) || v_delimiter;
                ELSE
                    v_next_seek := lower(v_current.name);
                END IF;

                EXIT WHEN v_count >= v_limit;
            END LOOP;
        END IF;
    END LOOP;
END;
$_$;


--
-- Name: search_by_timestamp(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_by_timestamp(p_prefix text, p_bucket_id text, p_limit integer, p_level integer, p_start_after text, p_sort_order text, p_sort_column text, p_sort_column_after text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    v_cursor_op text;
    v_query text;
    v_prefix text;
BEGIN
    v_prefix := coalesce(p_prefix, '');

    IF p_sort_order = 'asc' THEN
        v_cursor_op := '>';
    ELSE
        v_cursor_op := '<';
    END IF;

    v_query := format($sql$
        WITH raw_objects AS (
            SELECT
                o.name AS obj_name,
                o.id AS obj_id,
                o.updated_at AS obj_updated_at,
                o.created_at AS obj_created_at,
                o.last_accessed_at AS obj_last_accessed_at,
                o.metadata AS obj_metadata,
                storage.get_common_prefix(o.name, $1, '/') AS common_prefix
            FROM storage.objects o
            WHERE o.bucket_id = $2
              AND o.name COLLATE "C" LIKE $1 || '%%'
        ),
        -- Aggregate common prefixes (folders)
        -- Both created_at and updated_at use MIN(obj_created_at) to match the old prefixes table behavior
        aggregated_prefixes AS (
            SELECT
                rtrim(common_prefix, '/') AS name,
                NULL::uuid AS id,
                MIN(obj_created_at) AS updated_at,
                MIN(obj_created_at) AS created_at,
                NULL::timestamptz AS last_accessed_at,
                NULL::jsonb AS metadata,
                TRUE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NOT NULL
            GROUP BY common_prefix
        ),
        leaf_objects AS (
            SELECT
                obj_name AS name,
                obj_id AS id,
                obj_updated_at AS updated_at,
                obj_created_at AS created_at,
                obj_last_accessed_at AS last_accessed_at,
                obj_metadata AS metadata,
                FALSE AS is_prefix
            FROM raw_objects
            WHERE common_prefix IS NULL
        ),
        combined AS (
            SELECT * FROM aggregated_prefixes
            UNION ALL
            SELECT * FROM leaf_objects
        ),
        filtered AS (
            SELECT *
            FROM combined
            WHERE (
                $5 = ''
                OR ROW(
                    date_trunc('milliseconds', %I),
                    name COLLATE "C"
                ) %s ROW(
                    COALESCE(NULLIF($6, '')::timestamptz, 'epoch'::timestamptz),
                    $5
                )
            )
        )
        SELECT
            split_part(name, '/', $3) AS key,
            name,
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
        FROM filtered
        ORDER BY
            COALESCE(date_trunc('milliseconds', %I), 'epoch'::timestamptz) %s,
            name COLLATE "C" %s
        LIMIT $4
    $sql$,
        p_sort_column,
        v_cursor_op,
        p_sort_column,
        p_sort_order,
        p_sort_order
    );

    RETURN QUERY EXECUTE v_query
    USING v_prefix, p_bucket_id, p_level, p_limit, p_start_after, p_sort_column_after;
END;
$_$;


--
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $$
DECLARE
    v_sort_col text;
    v_sort_ord text;
    v_limit int;
BEGIN
    -- Cap limit to maximum of 1500 records
    v_limit := LEAST(coalesce(limits, 100), 1500);

    -- Validate and normalize sort_order
    v_sort_ord := lower(coalesce(sort_order, 'asc'));
    IF v_sort_ord NOT IN ('asc', 'desc') THEN
        v_sort_ord := 'asc';
    END IF;

    -- Validate and normalize sort_column
    v_sort_col := lower(coalesce(sort_column, 'name'));
    IF v_sort_col NOT IN ('name', 'updated_at', 'created_at') THEN
        v_sort_col := 'name';
    END IF;

    -- Route to appropriate implementation
    IF v_sort_col = 'name' THEN
        -- Use list_objects_with_delimiter for name sorting (most efficient: O(k * log n))
        RETURN QUERY
        SELECT
            split_part(l.name, '/', levels) AS key,
            l.name AS name,
            l.id,
            l.updated_at,
            l.created_at,
            l.last_accessed_at,
            l.metadata
        FROM storage.list_objects_with_delimiter(
            bucket_name,
            coalesce(prefix, ''),
            '/',
            v_limit,
            start_after,
            '',
            v_sort_ord
        ) l;
    ELSE
        -- Use aggregation approach for timestamp sorting
        -- Not efficient for large datasets but supports correct pagination
        RETURN QUERY SELECT * FROM storage.search_by_timestamp(
            prefix, bucket_name, v_limit, levels, start_after,
            v_sort_ord, v_sort_col, sort_column_after
        );
    END IF;
END;
$$;


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: -
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: custom_oauth_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.custom_oauth_providers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider_type text NOT NULL,
    identifier text NOT NULL,
    name text NOT NULL,
    client_id text NOT NULL,
    client_secret text NOT NULL,
    acceptable_client_ids text[] DEFAULT '{}'::text[] NOT NULL,
    scopes text[] DEFAULT '{}'::text[] NOT NULL,
    pkce_enabled boolean DEFAULT true NOT NULL,
    attribute_mapping jsonb DEFAULT '{}'::jsonb NOT NULL,
    authorization_params jsonb DEFAULT '{}'::jsonb NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    email_optional boolean DEFAULT false NOT NULL,
    issuer text,
    discovery_url text,
    skip_nonce_check boolean DEFAULT false NOT NULL,
    cached_discovery jsonb,
    discovery_cached_at timestamp with time zone,
    authorization_url text,
    token_url text,
    userinfo_url text,
    jwks_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT custom_oauth_providers_authorization_url_https CHECK (((authorization_url IS NULL) OR (authorization_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_authorization_url_length CHECK (((authorization_url IS NULL) OR (char_length(authorization_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_client_id_length CHECK (((char_length(client_id) >= 1) AND (char_length(client_id) <= 512))),
    CONSTRAINT custom_oauth_providers_discovery_url_length CHECK (((discovery_url IS NULL) OR (char_length(discovery_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_identifier_format CHECK ((identifier ~ '^[a-z0-9][a-z0-9:-]{0,48}[a-z0-9]$'::text)),
    CONSTRAINT custom_oauth_providers_issuer_length CHECK (((issuer IS NULL) OR ((char_length(issuer) >= 1) AND (char_length(issuer) <= 2048)))),
    CONSTRAINT custom_oauth_providers_jwks_uri_https CHECK (((jwks_uri IS NULL) OR (jwks_uri ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_jwks_uri_length CHECK (((jwks_uri IS NULL) OR (char_length(jwks_uri) <= 2048))),
    CONSTRAINT custom_oauth_providers_name_length CHECK (((char_length(name) >= 1) AND (char_length(name) <= 100))),
    CONSTRAINT custom_oauth_providers_oauth2_requires_endpoints CHECK (((provider_type <> 'oauth2'::text) OR ((authorization_url IS NOT NULL) AND (token_url IS NOT NULL) AND (userinfo_url IS NOT NULL)))),
    CONSTRAINT custom_oauth_providers_oidc_discovery_url_https CHECK (((provider_type <> 'oidc'::text) OR (discovery_url IS NULL) OR (discovery_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_issuer_https CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NULL) OR (issuer ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_oidc_requires_issuer CHECK (((provider_type <> 'oidc'::text) OR (issuer IS NOT NULL))),
    CONSTRAINT custom_oauth_providers_provider_type_check CHECK ((provider_type = ANY (ARRAY['oauth2'::text, 'oidc'::text]))),
    CONSTRAINT custom_oauth_providers_token_url_https CHECK (((token_url IS NULL) OR (token_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_token_url_length CHECK (((token_url IS NULL) OR (char_length(token_url) <= 2048))),
    CONSTRAINT custom_oauth_providers_userinfo_url_https CHECK (((userinfo_url IS NULL) OR (userinfo_url ~~ 'https://%'::text))),
    CONSTRAINT custom_oauth_providers_userinfo_url_length CHECK (((userinfo_url IS NULL) OR (char_length(userinfo_url) <= 2048)))
);


--
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text,
    code_challenge_method auth.code_challenge_method,
    code_challenge text,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone,
    invite_token text,
    referrer text,
    oauth_client_state_id uuid,
    linking_target_id uuid,
    email_optional boolean DEFAULT false NOT NULL
);


--
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.flow_state IS 'Stores metadata for all OAuth/SSO login flows';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


--
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


--
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    token_endpoint_auth_method text NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048)),
    CONSTRAINT oauth_clients_token_endpoint_auth_method_check CHECK ((token_endpoint_auth_method = ANY (ARRAY['client_secret_basic'::text, 'client_secret_post'::text, 'none'::text])))
);


--
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


--
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: -
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: -
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: webauthn_challenges; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_challenges (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid,
    challenge_type text NOT NULL,
    session_data jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    CONSTRAINT webauthn_challenges_challenge_type_check CHECK ((challenge_type = ANY (ARRAY['signup'::text, 'registration'::text, 'authentication'::text])))
);


--
-- Name: webauthn_credentials; Type: TABLE; Schema: auth; Owner: -
--

CREATE TABLE auth.webauthn_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    credential_id bytea NOT NULL,
    public_key bytea NOT NULL,
    attestation_type text DEFAULT ''::text NOT NULL,
    aaguid uuid,
    sign_count bigint DEFAULT 0 NOT NULL,
    transports jsonb DEFAULT '[]'::jsonb NOT NULL,
    backup_eligible boolean DEFAULT false NOT NULL,
    backed_up boolean DEFAULT false NOT NULL,
    friendly_name text DEFAULT ''::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_used_at timestamp with time zone
);


--
-- Name: categoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.categoria (
    id_categoria integer NOT NULL,
    nome character varying(150) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: categoria_id_categoria_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.categoria_id_categoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: categoria_id_categoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.categoria_id_categoria_seq OWNED BY public.categoria.id_categoria;


--
-- Name: contatos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contatos (
    id_contato integer NOT NULL,
    id_empresa integer NOT NULL,
    nome character varying(150) NOT NULL,
    telefone character varying(20),
    celular character varying(20),
    email character varying(150) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: contatos_id_contato_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contatos_id_contato_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contatos_id_contato_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contatos_id_contato_seq OWNED BY public.contatos.id_contato;


--
-- Name: cupons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cupons (
    id_cupom integer NOT NULL,
    codigo character varying(50) NOT NULL,
    tipo character varying(50) NOT NULL,
    valor numeric(10,2) NOT NULL,
    validade_inicio date,
    validade_fim date,
    ativo boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: cupons_id_cupom_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cupons_id_cupom_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cupons_id_cupom_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cupons_id_cupom_seq OWNED BY public.cupons.id_cupom;


--
-- Name: email_token; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_token (
    id_email integer NOT NULL,
    id_empresa integer NOT NULL,
    token character varying(150) NOT NULL,
    tipo public.email_token_type_enum NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '01:00:00'::interval)
);


--
-- Name: email_token_id_email_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_token_id_email_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_token_id_email_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_token_id_email_seq OWNED BY public.email_token.id_email;


--
-- Name: empresas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.empresas (
    id_empresa integer NOT NULL,
    cnpj character varying(255) NOT NULL,
    razao_social character varying(255) NOT NULL,
    nome_fantasia character varying(255) NOT NULL,
    senha_hash character varying(255) NOT NULL,
    perfil public.perfil_enum DEFAULT 'CLIENTE'::public.perfil_enum NOT NULL,
    ativo boolean DEFAULT true NOT NULL,
    id_vendedor integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: empresas_id_empresa_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.empresas_id_empresa_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: empresas_id_empresa_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.empresas_id_empresa_seq OWNED BY public.empresas.id_empresa;


--
-- Name: enderecos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.enderecos (
    id_endereco integer NOT NULL,
    id_empresa integer NOT NULL,
    cep character varying(20) NOT NULL,
    numero character varying(20) NOT NULL,
    complemento character varying(100),
    bairro character varying(100),
    cidade character varying(100),
    uf character(2) NOT NULL,
    ibge character varying(20),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: enderecos_id_endereco_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.enderecos_id_endereco_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: enderecos_id_endereco_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.enderecos_id_endereco_seq OWNED BY public.enderecos.id_endereco;


--
-- Name: imagens_produto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.imagens_produto (
    id_imagem integer NOT NULL,
    id_produto integer NOT NULL,
    url text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: imagens_produto_id_imagem_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.imagens_produto_id_imagem_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: imagens_produto_id_imagem_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.imagens_produto_id_imagem_seq OWNED BY public.imagens_produto.id_imagem;


--
-- Name: itens_pedido; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.itens_pedido (
    id_item integer NOT NULL,
    id_pedido integer NOT NULL,
    id_produto integer NOT NULL,
    quantidade integer NOT NULL,
    preco_unitario numeric(10,2) NOT NULL,
    subtotal numeric(10,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: itens_pedido_id_item_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.itens_pedido_id_item_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: itens_pedido_id_item_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.itens_pedido_id_item_seq OWNED BY public.itens_pedido.id_item;


--
-- Name: pedidos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pedidos (
    id_pedido integer NOT NULL,
    id_cliente integer NOT NULL,
    id_cupom integer,
    status character varying(50) NOT NULL,
    valor_total numeric(10,2) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pedidos_id_pedido_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pedidos_id_pedido_seq OWNED BY public.pedidos.id_pedido;


--
-- Name: precos_produto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.precos_produto (
    id_preco integer NOT NULL,
    id_produto integer NOT NULL,
    id_regiao integer NOT NULL,
    preco_0 numeric NOT NULL,
    preco_30 numeric NOT NULL,
    preco_60 numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: precos_produto_id_preco_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.precos_produto_id_preco_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: precos_produto_id_preco_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.precos_produto_id_preco_seq OWNED BY public.precos_produto.id_preco;


--
-- Name: produtos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.produtos (
    id_produto integer NOT NULL,
    codigo character varying(50) NOT NULL,
    nome character varying(150) NOT NULL,
    quantidade integer DEFAULT 1 NOT NULL,
    descricao text,
    cod_kit integer,
    id_categoria integer NOT NULL,
    id_subcategoria integer,
    valor_base numeric(10,2) NOT NULL,
    ativo boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: produtos_id_produto_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.produtos_id_produto_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: produtos_id_produto_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.produtos_id_produto_seq OWNED BY public.produtos.id_produto;


--
-- Name: regioes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.regioes (
    id_regiao integer NOT NULL,
    estado character varying(100) NOT NULL,
    desconto_0 numeric NOT NULL,
    desconto_30 numeric NOT NULL,
    desconto_60 numeric NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: regioes_id_regiao_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.regioes_id_regiao_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: regioes_id_regiao_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.regioes_id_regiao_seq OWNED BY public.regioes.id_regiao;


--
-- Name: subcategoria; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subcategoria (
    id_subcategoria integer NOT NULL,
    id_categoria bigint NOT NULL,
    nome character varying(150) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: subcategoria_id_subcategoria_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subcategoria_id_subcategoria_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subcategoria_id_subcategoria_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subcategoria_id_subcategoria_seq OWNED BY public.subcategoria.id_subcategoria;


--
-- Name: vendedor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vendedor (
    id_vendedor integer NOT NULL,
    nome character varying(150) NOT NULL
);


--
-- Name: vendedor_id_vendedor_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vendedor_id_vendedor_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vendedor_id_vendedor_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vendedor_id_vendedor_seq OWNED BY public.vendedor.id_vendedor;


--
-- Name: messages; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    binary_payload bytea
)
PARTITION BY RANGE (inserted_at);


--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: -
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL,
    action_filter text DEFAULT '*'::text,
    selected_columns text[],
    CONSTRAINT subscription_action_filter_check CHECK ((action_filter = ANY (ARRAY['*'::text, 'INSERT'::text, 'UPDATE'::text, 'DELETE'::text])))
);


--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: -
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


--
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


--
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: objects; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb
);


--
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: -
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb,
    metadata jsonb
);


--
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: -
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Name: categoria id_categoria; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categoria ALTER COLUMN id_categoria SET DEFAULT nextval('public.categoria_id_categoria_seq'::regclass);


--
-- Name: contatos id_contato; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contatos ALTER COLUMN id_contato SET DEFAULT nextval('public.contatos_id_contato_seq'::regclass);


--
-- Name: cupons id_cupom; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cupons ALTER COLUMN id_cupom SET DEFAULT nextval('public.cupons_id_cupom_seq'::regclass);


--
-- Name: email_token id_email; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_token ALTER COLUMN id_email SET DEFAULT nextval('public.email_token_id_email_seq'::regclass);


--
-- Name: empresas id_empresa; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas ALTER COLUMN id_empresa SET DEFAULT nextval('public.empresas_id_empresa_seq'::regclass);


--
-- Name: enderecos id_endereco; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enderecos ALTER COLUMN id_endereco SET DEFAULT nextval('public.enderecos_id_endereco_seq'::regclass);


--
-- Name: imagens_produto id_imagem; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imagens_produto ALTER COLUMN id_imagem SET DEFAULT nextval('public.imagens_produto_id_imagem_seq'::regclass);


--
-- Name: itens_pedido id_item; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itens_pedido ALTER COLUMN id_item SET DEFAULT nextval('public.itens_pedido_id_item_seq'::regclass);


--
-- Name: pedidos id_pedido; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos ALTER COLUMN id_pedido SET DEFAULT nextval('public.pedidos_id_pedido_seq'::regclass);


--
-- Name: precos_produto id_preco; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.precos_produto ALTER COLUMN id_preco SET DEFAULT nextval('public.precos_produto_id_preco_seq'::regclass);


--
-- Name: produtos id_produto; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produtos ALTER COLUMN id_produto SET DEFAULT nextval('public.produtos_id_produto_seq'::regclass);


--
-- Name: regioes id_regiao; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regioes ALTER COLUMN id_regiao SET DEFAULT nextval('public.regioes_id_regiao_seq'::regclass);


--
-- Name: subcategoria id_subcategoria; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcategoria ALTER COLUMN id_subcategoria SET DEFAULT nextval('public.subcategoria_id_subcategoria_seq'::regclass);


--
-- Name: vendedor id_vendedor; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendedor ALTER COLUMN id_vendedor SET DEFAULT nextval('public.vendedor_id_vendedor_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: custom_oauth_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.custom_oauth_providers (id, provider_type, identifier, name, client_id, client_secret, acceptable_client_ids, scopes, pkce_enabled, attribute_mapping, authorization_params, enabled, email_optional, issuer, discovery_url, skip_nonce_check, cached_discovery, discovery_cached_at, authorization_url, token_url, userinfo_url, jwks_uri, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: flow_state; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.flow_state (id, user_id, auth_code, code_challenge_method, code_challenge, provider_type, provider_access_token, provider_refresh_token, created_at, updated_at, authentication_method, auth_code_issued_at, invite_token, referrer, oauth_client_state_id, linking_target_id, email_optional) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at, id) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address, otp_code, web_authn_session_data) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret, phone, last_challenged_at, web_authn_credential, web_authn_aaguid, last_webauthn_challenge_data) FROM stdin;
\.


--
-- Data for Name: oauth_authorizations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_authorizations (id, authorization_id, client_id, user_id, redirect_uri, scope, state, resource, code_challenge, code_challenge_method, response_type, status, authorization_code, created_at, expires_at, approved_at, nonce) FROM stdin;
\.


--
-- Data for Name: oauth_client_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_client_states (id, provider_type, code_verifier, created_at) FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_clients (id, client_secret_hash, registration_type, redirect_uris, grant_types, client_name, client_uri, logo_uri, created_at, updated_at, deleted_at, client_type, token_endpoint_auth_method) FROM stdin;
\.


--
-- Data for Name: oauth_consents; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.oauth_consents (id, user_id, client_id, scopes, granted_at, revoked_at) FROM stdin;
\.


--
-- Data for Name: one_time_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.one_time_tokens (id, user_id, token_type, token_hash, relates_to, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at, name_id_format) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, created_at, updated_at, flow_state_id) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221125140132
20221208132122
20221215195500
20221215195800
20221215195900
20230116124310
20230116124412
20230131181311
20230322519590
20230402418590
20230411005111
20230508135423
20230523124323
20230818113222
20230914180801
20231027141322
20231114161723
20231117164230
20240115144230
20240214120130
20240306115329
20240314092811
20240427152123
20240612123726
20240729123726
20240802193726
20240806073726
20241009103726
20250717082212
20250731150234
20250804100000
20250901200500
20250903112500
20250904133000
20250925093508
20251007112900
20251104100000
20251111201300
20251201000000
20260115000000
20260121000000
20260219120000
20260302000000
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after, refreshed_at, user_agent, ip, tag, oauth_client_id, refresh_token_hmac_key, refresh_token_counter, scopes) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at, disabled) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user, deleted_at, is_anonymous) FROM stdin;
\.


--
-- Data for Name: webauthn_challenges; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_challenges (id, user_id, challenge_type, session_data, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: webauthn_credentials; Type: TABLE DATA; Schema: auth; Owner: -
--

COPY auth.webauthn_credentials (id, user_id, credential_id, public_key, attestation_type, aaguid, sign_count, transports, backup_eligible, backed_up, friendly_name, created_at, updated_at, last_used_at) FROM stdin;
\.


--
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.categoria (id_categoria, nome, created_at, updated_at) FROM stdin;
1	LINHA PANELA DE PRESSÃO	2025-12-15 19:46:34.068252+00	2025-12-15 19:46:34.068252+00
2	PANELAS E CAÇAROLAS	2025-12-15 19:48:14.234584+00	2025-12-15 19:48:14.234584+00
5	FRIGIDEIRAS	2025-12-15 19:49:59.03353+00	2025-12-15 19:49:59.03353+00
6	FORMAS E ASSADEIRAS	2025-12-15 19:50:33.004435+00	2025-12-15 19:50:33.004435+00
7	WOKS E PAELLEIRAS	2025-12-15 19:51:09.521816+00	2025-12-15 19:51:09.521816+00
8	COPOS E CANECAS	2025-12-15 19:51:42.382019+00	2025-12-15 19:51:42.382019+00
9	JARRAS	2025-12-15 19:52:08.822372+00	2025-12-15 19:52:08.822372+00
10	MARMITAS E JOGOS DE MARMITA	2025-12-15 19:52:43.26062+00	2025-12-15 19:52:43.26062+00
12	BACIAS E BALDES	2025-12-15 19:53:57.165661+00	2025-12-15 19:53:57.165661+00
13	LAVARROZ E ESCORREDORES	2025-12-15 19:54:28.71062+00	2025-12-15 19:54:28.71062+00
14	BULE - CHALEIRA - CAFETEIRA	2025-12-15 19:54:57.729174+00	2025-12-15 19:54:57.729174+00
16	CUSCUZEIROS	2025-12-15 19:55:57.175788+00	2025-12-15 19:55:57.175788+00
18	PIPOQUEIRAS	2025-12-15 19:56:57.235483+00	2025-12-15 19:56:57.235483+00
19	MORINGA	2025-12-15 19:57:54.402961+00	2025-12-15 19:57:54.402961+00
21	ESPAGUETEIRAS	2025-12-15 19:58:55.964641+00	2025-12-15 19:58:55.964641+00
22	CONCHA - ESPUMADEIRA	2025-12-15 19:59:32.954953+00	2025-12-15 19:59:32.954953+00
23	TAMPAS AVULSAS	2025-12-15 20:00:22.405758+00	2025-12-15 20:00:22.405758+00
24	JOGOS DE PANELAS	2025-12-15 20:01:01.825615+00	2025-12-15 20:01:01.825615+00
25	KIT FEIRINHA	2025-12-15 20:01:49.552108+00	2025-12-15 20:01:49.552108+00
17	PANELA BANHO MARIA	2025-12-15 19:56:30.258024+00	2025-12-15 20:08:49.177167+00
4	CANECÕES E FERVEDORES	2025-12-15 19:49:23.237215+00	2026-03-25 14:55:32.86581+00
11	DEPÓSITO DE MANTIMENTOS	2025-12-15 19:53:07.918311+00	2026-03-25 14:56:39.430867+00
15	LATÃO DE LEITE	2025-12-15 19:55:24.615847+00	2026-03-25 14:56:56.450886+00
20	FILTRA ÓLEO	2025-12-15 19:58:20.924969+00	2026-03-25 14:57:08.364934+00
3	CALDEIROES	2025-12-15 19:48:46.480684+00	2026-03-25 17:29:41.31769+00
\.


--
-- Data for Name: contatos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.contatos (id_contato, id_empresa, nome, telefone, celular, email, created_at, updated_at) FROM stdin;
12	13	Vinicius	16 99781-4524	16 99781-4524	sitefortlar@gmail.com	2025-12-13 12:31:46.909732+00	2025-12-13 12:31:46.909732+00
13	14	Antonio	16997974558	16997936558	levai.automations@gmail.com	2026-01-28 19:39:51.647382+00	2026-01-28 19:39:51.647382+00
14	15	Vinicius Ramos	16 997814524	16 997814524	vinicius@fortlar.com.br	2026-02-04 14:35:51.174803+00	2026-02-04 14:35:51.174803+00
\.


--
-- Data for Name: cupons; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cupons (id_cupom, codigo, tipo, valor, validade_inicio, validade_fim, ativo, created_at, updated_at) FROM stdin;
1	DESCONTAO	PERCENTUAL	50.00	2026-01-17	2026-01-22	t	2026-01-17 13:37:55.487217+00	2026-01-20 15:36:21.697067+00
\.


--
-- Data for Name: email_token; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.email_token (id_email, id_empresa, token, tipo, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: empresas; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.empresas (id_empresa, cnpj, razao_social, nome_fantasia, senha_hash, perfil, ativo, id_vendedor, created_at, updated_at) FROM stdin;
13	$2b$12$8WfOTu3nflpwUr.nG3dNXe/wtP1cq8c6QdXyRfGk3tjxcxGkxrGCq	ALUMINIO FORT LAR INDUSTRIA E COMERCIO DE ARTEFATOS DE ALUMINIO LTDA	FORT LAR	$2b$12$SeXHKkOpqmuwIx20AuOtme8EXL2h2Rh15ZuDz8xVqOVV6szH7BqeW	ADMIN	t	1	2025-12-13 12:31:46.909732+00	2025-12-13 19:28:01.445759+00
14	$2b$12$tH30dia3Ja/Hprk/cOj3DOdc7UcUTjmdbTohrQ.pTYXjWmPknOnYm	ANTONIO JOELSON DE LIMA 21278880810	Loja	$2b$12$60ncBCugFFs58FXxCTJwk.aHvNTEw9N9rElAvl/A0lATnRIdEQ8Lq	CLIENTE	t	1	2026-01-28 19:39:51.647382+00	2026-01-28 19:42:14.991325+00
15	$2b$12$0GzZL8LlcuMGSsVkudgr4OzxG1GwR3NNqhm/r7CzGUaRya.GnQVGS	CCR DA SILVA	DONNA MAGNOLIA	$2b$12$IJBpeytOtUyDJ3ysI7V/7ur9q85yRddbYGr7yqS82R16iqmVqpCPu	CLIENTE	t	1	2026-02-04 14:35:51.174803+00	2026-02-04 14:36:17.8895+00
\.


--
-- Data for Name: enderecos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.enderecos (id_endereco, id_empresa, cep, numero, complemento, bairro, cidade, uf, ibge, created_at, updated_at) FROM stdin;
12	13	14807415	789	FORT LAR	JARDIM PORTUGAL	ARARAQUARA	SP		2025-12-13 12:31:46.909732+00	2025-12-13 12:31:46.909732+00
13	14	15047251	100	loja	JARDIM ARROYO	SAO JOSE DO RIO PRETO	SP		2026-01-28 19:39:51.647382+00	2026-01-28 19:39:51.647382+00
14	15	14806-448	279	Res Veneto	Jardim Residencial Maggiore	Araraquara	SP		2026-02-04 14:35:51.174803+00	2026-02-04 14:35:51.174803+00
\.


--
-- Data for Name: imagens_produto; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.imagens_produto (id_imagem, id_produto, url, created_at, updated_at) FROM stdin;
2321	2902	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1KnFlb90SdTcoJFpj4xOLqTTDkWb9tQMF.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2322	2902	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2323	2902	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZmRuUT3L8kfZDXPJ6I9lso3lu7QggMoY.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2324	2903	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1KnFlb90SdTcoJFpj4xOLqTTDkWb9tQMF.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2325	2903	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2326	2903	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZmRuUT3L8kfZDXPJ6I9lso3lu7QggMoY.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2327	2904	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1KnFlb90SdTcoJFpj4xOLqTTDkWb9tQMF.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2328	2904	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2329	2904	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZmRuUT3L8kfZDXPJ6I9lso3lu7QggMoY.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2330	2905	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1w3Z06tvD_SUGAHiyM_rRTtx8aE7bNLBJ.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2331	2905	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2332	2905	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDh6Ca3m_ItznQSCoAG5d_viebfMsf3G.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2333	2906	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1w3Z06tvD_SUGAHiyM_rRTtx8aE7bNLBJ.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2334	2906	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2335	2906	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDh6Ca3m_ItznQSCoAG5d_viebfMsf3G.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2336	2907	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1w3Z06tvD_SUGAHiyM_rRTtx8aE7bNLBJ.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2337	2907	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2338	2907	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDh6Ca3m_ItznQSCoAG5d_viebfMsf3G.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2339	2908	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DzOSCP3kzDnWrdu3b08WTP23vmLNFfj1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2340	2908	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2341	2908	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZmRuUT3L8kfZDXPJ6I9lso3lu7QggMoY.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2342	2909	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DzOSCP3kzDnWrdu3b08WTP23vmLNFfj1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2343	2909	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2344	2909	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZmRuUT3L8kfZDXPJ6I9lso3lu7QggMoY.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2345	2910	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DzOSCP3kzDnWrdu3b08WTP23vmLNFfj1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2346	2910	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2347	2910	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZmRuUT3L8kfZDXPJ6I9lso3lu7QggMoY.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2348	2911	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WZqSj_inoJgU-Jh2jFmlQMymg7-XPifm.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2349	2911	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2350	2911	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDh6Ca3m_ItznQSCoAG5d_viebfMsf3G.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2351	2912	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WZqSj_inoJgU-Jh2jFmlQMymg7-XPifm.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2352	2912	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2353	2912	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDh6Ca3m_ItznQSCoAG5d_viebfMsf3G.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2354	2913	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WZqSj_inoJgU-Jh2jFmlQMymg7-XPifm.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2355	2913	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2356	2913	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDh6Ca3m_ItznQSCoAG5d_viebfMsf3G.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2357	2914	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2358	2914	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2359	2914	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2360	2914	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2361	2915	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2362	2915	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2363	2915	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2364	2915	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2365	2916	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2366	2916	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2367	2916	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2368	2916	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2369	2917	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2370	2917	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2371	2917	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2372	2917	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2373	2918	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2374	2918	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2375	2919	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2376	2919	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2377	2920	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2378	2920	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2379	2921	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2380	2921	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2381	2922	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2382	2922	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2383	2923	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2384	2923	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2385	2924	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2386	2924	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2387	2925	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2388	2925	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2389	2926	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2390	2926	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2391	2927	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2392	2927	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2393	2928	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2394	2928	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2395	2929	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2396	2929	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2397	2930	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2398	2930	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2399	2930	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2400	2930	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2401	2931	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2402	2931	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2403	2931	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2404	2931	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2405	2932	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2406	2932	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2407	2932	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2408	2932	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2409	2933	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2410	2933	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2411	2933	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2412	2933	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2413	2934	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1SHX-QMfIjxcqSWW51DeTj1QWV5CuEFZS.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2414	2934	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2415	2935	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1SHX-QMfIjxcqSWW51DeTj1QWV5CuEFZS.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2416	2935	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2417	2936	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1SHX-QMfIjxcqSWW51DeTj1QWV5CuEFZS.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2418	2936	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2419	2937	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2420	2937	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2421	2938	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2422	2938	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2423	2939	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2424	2939	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2425	2940	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2426	2940	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2427	2941	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2428	2941	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2429	2942	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2430	2942	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2431	2943	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2432	2943	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2433	2944	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2434	2944	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2435	2945	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2436	2945	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2437	2946	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2438	2946	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2439	2947	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2440	2947	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2441	2948	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2442	2948	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2443	2949	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2444	2949	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2445	2949	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2446	2950	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2447	2950	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2448	2950	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2449	2951	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2450	2951	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2451	2951	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2452	2952	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2453	2952	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2454	2952	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2455	2953	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1aWd-dF7szB9ZYLFu9FjYC_DpGYnhrp06.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2456	2953	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2457	2954	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1aWd-dF7szB9ZYLFu9FjYC_DpGYnhrp06.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2458	2954	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2459	2955	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1aWd-dF7szB9ZYLFu9FjYC_DpGYnhrp06.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2460	2955	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2461	2956	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2462	2956	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2463	2957	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2464	2957	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2465	2958	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2466	2958	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2467	2959	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2468	2959	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2469	2960	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1GgEThkbngNIaqtQMiXsAU1wypNsrnDLU.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2470	2960	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2471	2961	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1GgEThkbngNIaqtQMiXsAU1wypNsrnDLU.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2472	2961	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2473	2962	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1GgEThkbngNIaqtQMiXsAU1wypNsrnDLU.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2474	2962	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2475	2963	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1GgEThkbngNIaqtQMiXsAU1wypNsrnDLU.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2476	2963	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2477	2964	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_195ByNLosHqZG80iOP8ksi6tzGe9xQRJf.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2478	2964	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2479	2965	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_195ByNLosHqZG80iOP8ksi6tzGe9xQRJf.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2480	2965	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2481	2966	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_195ByNLosHqZG80iOP8ksi6tzGe9xQRJf.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2482	2966	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2483	2967	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_195ByNLosHqZG80iOP8ksi6tzGe9xQRJf.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2484	2967	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2485	2968	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2486	2968	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2487	2968	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2488	2969	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2489	2969	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2490	2969	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2491	2970	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2492	2970	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2493	2970	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2494	2971	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2495	2971	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2496	2971	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2497	2972	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1aWd-dF7szB9ZYLFu9FjYC_DpGYnhrp06.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2498	2972	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2499	2973	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1aWd-dF7szB9ZYLFu9FjYC_DpGYnhrp06.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2500	2973	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2501	2974	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1aWd-dF7szB9ZYLFu9FjYC_DpGYnhrp06.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2502	2974	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2503	2975	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2504	2975	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2505	2976	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2506	2976	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2507	2977	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2508	2977	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2509	2978	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1GgEThkbngNIaqtQMiXsAU1wypNsrnDLU.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2510	2978	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2511	2979	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1GgEThkbngNIaqtQMiXsAU1wypNsrnDLU.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2512	2979	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2513	2980	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1GgEThkbngNIaqtQMiXsAU1wypNsrnDLU.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2514	2980	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2515	2981	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_195ByNLosHqZG80iOP8ksi6tzGe9xQRJf.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2516	2981	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2517	2982	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_195ByNLosHqZG80iOP8ksi6tzGe9xQRJf.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2518	2982	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2519	2983	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_195ByNLosHqZG80iOP8ksi6tzGe9xQRJf.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2520	2983	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2521	2984	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2522	2984	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2523	2984	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2524	2985	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2525	2985	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2526	2985	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2527	2986	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2528	2986	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2529	2986	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2530	2987	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2531	2987	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2532	2988	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2533	2988	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2534	2989	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2535	2989	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2536	2990	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1dgh5vbufDaLfAzWQBAoMOgxId7Ad-ssA.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2537	2991	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1dgh5vbufDaLfAzWQBAoMOgxId7Ad-ssA.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2538	2992	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1dgh5vbufDaLfAzWQBAoMOgxId7Ad-ssA.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2539	2993	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cJidTSwhIvdl1AQSY_sXy4XBezQChNx9.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2540	2994	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bHdbHPCT28ACADnWBlTmo01k3lmFQ5La.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2541	2995	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1898v58_4BFt7mcfpB38--bvh3o9slG03.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2542	2996	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1898v58_4BFt7mcfpB38--bvh3o9slG03.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2543	2997	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1898v58_4BFt7mcfpB38--bvh3o9slG03.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2544	2998	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12uGSQyOVSme4gDDBPNomJgBrqEjNaUFg.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2545	2999	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XTHGsiEO3pXFJ_mu75JkwgN5Glf8eHMp.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2546	3000	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1YDkmP7ap2Xje6e2ifJW3qdoLn-ZhS1XU.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2547	3001	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1D8qx7XmTKUc1Np_KpKDX0PrWpfH5aXSH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2548	3002	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1D8qx7XmTKUc1Np_KpKDX0PrWpfH5aXSH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2549	3003	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1D8qx7XmTKUc1Np_KpKDX0PrWpfH5aXSH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2550	3004	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1D8qx7XmTKUc1Np_KpKDX0PrWpfH5aXSH.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2551	3005	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1qKYPYk4IoBnrBuVHbUCHccYTy6e-ZP61.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2552	3006	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cv3SoXUlGEeNLKmvnd4TfBC9iY6zeUp6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2553	3007	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cv3SoXUlGEeNLKmvnd4TfBC9iY6zeUp6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2554	3008	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cv3SoXUlGEeNLKmvnd4TfBC9iY6zeUp6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2555	3009	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cv3SoXUlGEeNLKmvnd4TfBC9iY6zeUp6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2556	3010	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cv3SoXUlGEeNLKmvnd4TfBC9iY6zeUp6.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2557	3011	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2558	3012	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1o1vit_FLlsMeR-67eo_HqTL9zjogHQ9R.jpg	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
2559	3013	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2560	3014	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2561	3015	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2562	3016	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2563	3017	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2564	3018	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2565	3019	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2566	3020	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2567	3021	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2568	3022	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2569	3023	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2570	3024	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2571	3025	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2572	3026	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2573	3027	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2574	3028	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2575	3029	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2576	3030	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2577	3031	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AffV03fOqj6fYJswWk_s331lyi66Z1s9.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2578	3032	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AffV03fOqj6fYJswWk_s331lyi66Z1s9.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2579	3033	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AffV03fOqj6fYJswWk_s331lyi66Z1s9.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2580	3034	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AffV03fOqj6fYJswWk_s331lyi66Z1s9.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2581	3035	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pbEAkWiAOoPx7DECnzMfFDlYC56a0I-6.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2582	3036	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pbEAkWiAOoPx7DECnzMfFDlYC56a0I-6.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2583	3037	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pbEAkWiAOoPx7DECnzMfFDlYC56a0I-6.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2584	3038	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pbEAkWiAOoPx7DECnzMfFDlYC56a0I-6.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2585	3039	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pbEAkWiAOoPx7DECnzMfFDlYC56a0I-6.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2586	3040	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2587	3041	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2588	3042	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2589	3043	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2590	3044	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2591	3045	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2592	3046	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2593	3047	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2594	3048	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2595	3049	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2596	3050	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2597	3051	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2598	3052	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2599	3053	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2600	3054	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2601	3055	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2602	3056	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2603	3057	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2604	3058	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2605	3059	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2606	3060	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2607	3061	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2608	3062	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2609	3063	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2610	3064	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2611	3065	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2612	3066	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2613	3067	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2614	3068	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2615	3069	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2616	3070	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2617	3071	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2618	3072	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2619	3073	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2620	3074	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2621	3075	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2622	3076	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2623	3077	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2624	3078	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WiqtiFN41tFhTz1bo9AEMobkAlvhc8G1.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2625	3079	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zm-vjLjhfI-svGjpJy9a83fUjQG83LEK.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2626	3080	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zm-vjLjhfI-svGjpJy9a83fUjQG83LEK.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2627	3081	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zm-vjLjhfI-svGjpJy9a83fUjQG83LEK.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2628	3082	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zm-vjLjhfI-svGjpJy9a83fUjQG83LEK.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2629	3083	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2630	3084	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2631	3085	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2632	3086	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2633	3087	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2634	3088	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2635	3089	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
2636	3090	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1izGlXB5lsU7Fat3eLVJmGl8RyT15_ZcW.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2637	3091	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1izGlXB5lsU7Fat3eLVJmGl8RyT15_ZcW.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2638	3092	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1izGlXB5lsU7Fat3eLVJmGl8RyT15_ZcW.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2639	3093	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1izGlXB5lsU7Fat3eLVJmGl8RyT15_ZcW.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2640	3094	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1u6KMzby5uopq0ecmsX-uYH0gZp9RbVQs.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2641	3095	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1u6KMzby5uopq0ecmsX-uYH0gZp9RbVQs.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2642	3096	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1u6KMzby5uopq0ecmsX-uYH0gZp9RbVQs.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2643	3097	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bp0zzZe6cCuoGYafoQk4GDMnMtgcaKi0.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2644	3098	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bp0zzZe6cCuoGYafoQk4GDMnMtgcaKi0.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2645	3099	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bp0zzZe6cCuoGYafoQk4GDMnMtgcaKi0.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2646	3100	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2647	3101	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2648	3102	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2649	3103	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2650	3104	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2651	3105	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2652	3106	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2653	3107	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2654	3108	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2655	3109	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2656	3110	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
2657	3111	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1OVakRBzhhGETngldlZHLSqGy_b9OUMA0.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2658	3112	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1OVakRBzhhGETngldlZHLSqGy_b9OUMA0.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2659	3113	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1OVakRBzhhGETngldlZHLSqGy_b9OUMA0.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2660	3114	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1OVakRBzhhGETngldlZHLSqGy_b9OUMA0.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2661	3115	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1OVakRBzhhGETngldlZHLSqGy_b9OUMA0.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2662	3116	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1OVakRBzhhGETngldlZHLSqGy_b9OUMA0.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2663	3117	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rkkqesWXo4ahfDzeypNfdnUs68olXdrq.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2664	3118	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rkkqesWXo4ahfDzeypNfdnUs68olXdrq.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2665	3119	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rkkqesWXo4ahfDzeypNfdnUs68olXdrq.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2666	3120	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rkkqesWXo4ahfDzeypNfdnUs68olXdrq.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2667	3121	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rkkqesWXo4ahfDzeypNfdnUs68olXdrq.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2668	3122	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rkkqesWXo4ahfDzeypNfdnUs68olXdrq.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2669	3123	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2670	3124	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2671	3125	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2672	3126	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2673	3127	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2674	3128	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2675	3129	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2676	3130	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2677	3131	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2678	3132	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2679	3133	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2680	3134	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2681	3135	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2682	3136	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2683	3137	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2684	3138	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2685	3139	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2686	3140	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2687	3141	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2688	3142	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2689	3143	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2690	3144	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2691	3145	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2692	3146	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2693	3147	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2694	3148	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2695	3149	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2696	3150	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2697	3151	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2698	3152	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2699	3153	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2700	3154	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2701	3155	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2702	3156	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2703	3157	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2704	3158	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2705	3159	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2706	3160	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_lmYOi27FXlRplRmQM_2xemQKoWj4Vkc.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2707	3161	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1YQK_KbXZ3r1Oo2rPY306hm5hbuRbJfyA.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2708	3162	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Brr1Xw2tCp4RNai0cVyf7dXa98psQu39.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2709	3163	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ztybT7pxQA4sIU2d7XsBC50T5ux9UPIz.jpg	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
2710	3164	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2711	3165	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2712	3166	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2713	3167	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2714	3168	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2715	3169	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2716	3170	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2717	3171	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2718	3172	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2719	3173	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2720	3174	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2721	3175	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2722	3176	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2723	3177	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2724	3178	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2725	3179	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2726	3180	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2727	3181	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2728	3182	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2729	3183	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2730	3184	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2731	3185	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2732	3186	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2733	3187	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2734	3188	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2735	3189	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2736	3190	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2737	3191	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2738	3192	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uX6MsIV6b1vT2n3kYPiZDM60_s1Odxvq.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2739	3193	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uX6MsIV6b1vT2n3kYPiZDM60_s1Odxvq.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2740	3194	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1q002d2QSr5uCYAQV11OETO_sIiba--vS.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2741	3195	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1q002d2QSr5uCYAQV11OETO_sIiba--vS.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2742	3196	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1q002d2QSr5uCYAQV11OETO_sIiba--vS.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2743	3197	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1q002d2QSr5uCYAQV11OETO_sIiba--vS.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2744	3198	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rYuhuj7TrfxqwIMP-NWhtB8MKdC64A_s.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2745	3199	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rYuhuj7TrfxqwIMP-NWhtB8MKdC64A_s.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2746	3200	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rYuhuj7TrfxqwIMP-NWhtB8MKdC64A_s.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2747	3201	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rYuhuj7TrfxqwIMP-NWhtB8MKdC64A_s.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2748	3202	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1rYuhuj7TrfxqwIMP-NWhtB8MKdC64A_s.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2749	3203	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12O6yhoDkaeRvcGfb-kFTxO-lfYziqwId.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2750	3204	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12O6yhoDkaeRvcGfb-kFTxO-lfYziqwId.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2751	3205	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12O6yhoDkaeRvcGfb-kFTxO-lfYziqwId.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2752	3206	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15nApI_PULYh67QaWppgIFC_5BDvTE7T1.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2753	3207	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15nApI_PULYh67QaWppgIFC_5BDvTE7T1.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2754	3208	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15nApI_PULYh67QaWppgIFC_5BDvTE7T1.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2755	3209	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1HxCbFcwslt1MnCzZKlGcHYHTWR0_abHF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2756	3210	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1HxCbFcwslt1MnCzZKlGcHYHTWR0_abHF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2757	3211	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1HxCbFcwslt1MnCzZKlGcHYHTWR0_abHF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2758	3212	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WJaBFiaO3py4Lx2VaPWNHZ8EJ0rhHKNf.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2759	3213	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WJaBFiaO3py4Lx2VaPWNHZ8EJ0rhHKNf.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2760	3214	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WJaBFiaO3py4Lx2VaPWNHZ8EJ0rhHKNf.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2761	3215	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1HxCbFcwslt1MnCzZKlGcHYHTWR0_abHF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2762	3216	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1HxCbFcwslt1MnCzZKlGcHYHTWR0_abHF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2763	3217	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1HxCbFcwslt1MnCzZKlGcHYHTWR0_abHF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2764	3218	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WJaBFiaO3py4Lx2VaPWNHZ8EJ0rhHKNf.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2765	3219	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WJaBFiaO3py4Lx2VaPWNHZ8EJ0rhHKNf.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2766	3220	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1WJaBFiaO3py4Lx2VaPWNHZ8EJ0rhHKNf.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2767	3221	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1vKQVV3LlxkcqfSYkfyCkKqdh0EW4bktv.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2768	3222	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1vKQVV3LlxkcqfSYkfyCkKqdh0EW4bktv.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2769	3223	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1vKQVV3LlxkcqfSYkfyCkKqdh0EW4bktv.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2770	3224	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2771	3225	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2772	3226	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2773	3227	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2774	3228	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2775	3229	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2776	3230	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2777	3231	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2778	3232	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2779	3233	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2780	3234	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2781	3235	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2782	3236	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2783	3237	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2784	3238	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2785	3239	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2786	3240	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2787	3241	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2788	3242	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2789	3243	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2790	3244	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1p7lExnu21q-lwTDjjjCPIvymyc79u3DD.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2791	3245	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1p7lExnu21q-lwTDjjjCPIvymyc79u3DD.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2792	3246	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1p7lExnu21q-lwTDjjjCPIvymyc79u3DD.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2793	3247	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1p7lExnu21q-lwTDjjjCPIvymyc79u3DD.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2794	3248	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15Zr1R1WqbH3sDnyJlaWnm0gvrxJnZQP-.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2795	3249	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15Zr1R1WqbH3sDnyJlaWnm0gvrxJnZQP-.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2796	3250	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2797	3251	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2798	3252	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2799	3253	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2800	3254	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2801	3255	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2802	3256	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2803	3257	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2804	3258	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2805	3259	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2806	3260	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2807	3261	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2808	3262	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2809	3263	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2810	3264	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2811	3265	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2812	3266	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2813	3267	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2814	3268	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1qLEkVYax-JnSlKKcWY3SHUQq_jFBHPQJ.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2815	3269	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1qLEkVYax-JnSlKKcWY3SHUQq_jFBHPQJ.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2816	3270	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1qLEkVYax-JnSlKKcWY3SHUQq_jFBHPQJ.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2817	3271	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1qLEkVYax-JnSlKKcWY3SHUQq_jFBHPQJ.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2818	3272	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1K3hX7k88FipY3fLNzpGKP5dtDm_ysUs9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2819	3273	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1K3hX7k88FipY3fLNzpGKP5dtDm_ysUs9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2820	3274	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1K3hX7k88FipY3fLNzpGKP5dtDm_ysUs9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2821	3275	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1K3hX7k88FipY3fLNzpGKP5dtDm_ysUs9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2822	3276	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1tK1dW86p9O0oL_FD9p163f_xZHjazrYC.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2823	3277	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1tK1dW86p9O0oL_FD9p163f_xZHjazrYC.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2824	3278	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1tK1dW86p9O0oL_FD9p163f_xZHjazrYC.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2825	3279	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1tK1dW86p9O0oL_FD9p163f_xZHjazrYC.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2826	3280	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2827	3281	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2828	3282	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2829	3283	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2830	3284	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2831	3285	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2832	3286	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2833	3287	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2834	3288	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2835	3289	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2836	3290	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DQapGZ2GhTtYu4gvZSZbiZqQwaqiOygW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2837	3291	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DQapGZ2GhTtYu4gvZSZbiZqQwaqiOygW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2838	3292	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DQapGZ2GhTtYu4gvZSZbiZqQwaqiOygW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2839	3293	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DQapGZ2GhTtYu4gvZSZbiZqQwaqiOygW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2840	3294	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DQapGZ2GhTtYu4gvZSZbiZqQwaqiOygW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2841	3295	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DQapGZ2GhTtYu4gvZSZbiZqQwaqiOygW.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2842	3296	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IWZORDEI-ixXllNrTbNJjmL5VsV1mVNh.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2843	3297	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IWZORDEI-ixXllNrTbNJjmL5VsV1mVNh.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2844	3298	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IWZORDEI-ixXllNrTbNJjmL5VsV1mVNh.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2845	3299	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IWZORDEI-ixXllNrTbNJjmL5VsV1mVNh.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2846	3300	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IWZORDEI-ixXllNrTbNJjmL5VsV1mVNh.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2847	3301	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1IWZORDEI-ixXllNrTbNJjmL5VsV1mVNh.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2848	3302	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ucroNKI5EhwhHlACdYSWH4_ktCbCBllE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2849	3303	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ucroNKI5EhwhHlACdYSWH4_ktCbCBllE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2850	3304	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ucroNKI5EhwhHlACdYSWH4_ktCbCBllE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2851	3305	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ucroNKI5EhwhHlACdYSWH4_ktCbCBllE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2852	3306	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ucroNKI5EhwhHlACdYSWH4_ktCbCBllE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2853	3307	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ucroNKI5EhwhHlACdYSWH4_ktCbCBllE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2854	3308	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uXT0Qoi1x1B6_FSGNUxEiVWqePJHGDTr.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2855	3309	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uXT0Qoi1x1B6_FSGNUxEiVWqePJHGDTr.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2856	3310	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uXT0Qoi1x1B6_FSGNUxEiVWqePJHGDTr.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2857	3311	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uXT0Qoi1x1B6_FSGNUxEiVWqePJHGDTr.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2858	3312	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uXT0Qoi1x1B6_FSGNUxEiVWqePJHGDTr.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2859	3313	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uXT0Qoi1x1B6_FSGNUxEiVWqePJHGDTr.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2860	3314	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2861	3315	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2862	3316	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2863	3317	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2864	3318	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2865	3319	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2866	3320	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2867	3321	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2868	3322	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1a8YMaJhxX5DelmZg89HI7_mm1xGa5B4c.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2869	3323	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1a8YMaJhxX5DelmZg89HI7_mm1xGa5B4c.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2870	3324	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AJBgvVClkqmR3TpvgEDGHtnG8s-r8zDE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2871	3325	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AJBgvVClkqmR3TpvgEDGHtnG8s-r8zDE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2872	3326	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AJBgvVClkqmR3TpvgEDGHtnG8s-r8zDE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2873	3327	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AJBgvVClkqmR3TpvgEDGHtnG8s-r8zDE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2874	3328	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AJBgvVClkqmR3TpvgEDGHtnG8s-r8zDE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2875	3329	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AJBgvVClkqmR3TpvgEDGHtnG8s-r8zDE.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2876	3330	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QTEOtLWGRhncqU-qrl6eCyf8Rcfy5DzF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2877	3331	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QTEOtLWGRhncqU-qrl6eCyf8Rcfy5DzF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2878	3332	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1QTEOtLWGRhncqU-qrl6eCyf8Rcfy5DzF.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2879	3333	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bvbmw3FgqsJR90O1Mm65CcpHxCmNMxJL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2880	3334	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bvbmw3FgqsJR90O1Mm65CcpHxCmNMxJL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2881	3335	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bvbmw3FgqsJR90O1Mm65CcpHxCmNMxJL.jpg	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
2898	3352	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_14gd5LXGmEkGtkrtkP4CTZK7bx2khGrp3.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2899	3353	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_14gd5LXGmEkGtkrtkP4CTZK7bx2khGrp3.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2900	3354	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1h6BMe6xyL6KHyk12fwK4nxdnYkTjksDX.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2901	3355	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1h6BMe6xyL6KHyk12fwK4nxdnYkTjksDX.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2902	3356	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1h6BMe6xyL6KHyk12fwK4nxdnYkTjksDX.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2903	3357	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1h6BMe6xyL6KHyk12fwK4nxdnYkTjksDX.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2904	3358	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1h6BMe6xyL6KHyk12fwK4nxdnYkTjksDX.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2905	3359	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1h6BMe6xyL6KHyk12fwK4nxdnYkTjksDX.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2906	3360	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2907	3361	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2908	3362	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2909	3363	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2910	3364	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2911	3365	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2912	3366	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2913	3367	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2914	3368	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1YLYJjL1SzXLVYLJqhMT5vgVexYOUJb0S.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2915	3369	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2916	3370	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2917	3371	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pmNU3bFCavf2LS-QT-BdwymsKWKJyg_f.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2918	3372	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pmNU3bFCavf2LS-QT-BdwymsKWKJyg_f.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2919	3373	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pmNU3bFCavf2LS-QT-BdwymsKWKJyg_f.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2920	3374	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1pmNU3bFCavf2LS-QT-BdwymsKWKJyg_f.jpg	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
2938	3392	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2939	3393	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2940	3394	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2941	3395	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2942	3396	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2943	3397	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2944	3398	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2945	3399	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2946	3400	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2947	3401	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2948	3402	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2949	3403	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gJQDz38MDgiDyYjml0xMkAT33oaVdLKI.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2950	3404	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ioMkYVymn7lP1Y98V2IyhIg77nOYDl7m.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2951	3405	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ioMkYVymn7lP1Y98V2IyhIg77nOYDl7m.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2952	3405	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1d8pzHRsmIRWUSUnRC_sw8jQPTcyzjHd6.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2953	3406	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ioMkYVymn7lP1Y98V2IyhIg77nOYDl7m.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2954	3406	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1d8pzHRsmIRWUSUnRC_sw8jQPTcyzjHd6.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
2955	3407	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1tBuiXUp0EWuQg-cJpwhAIWxmt9lsrIFM.jpg	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3265	3336	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1vWeuIQ3xnKFBk-2aVSYWu-e6cdHujtBN.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3266	3337	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uEoJDbVrtXsmvWADdkAErxdaB5YiS9kR.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3267	3338	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1vWeuIQ3xnKFBk-2aVSYWu-e6cdHujtBN.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3268	3339	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uEoJDbVrtXsmvWADdkAErxdaB5YiS9kR.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3269	3340	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1mGkfT_9WK-jAZ1hPPWJ9emLPS66xQDe7.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3270	3341	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1mGkfT_9WK-jAZ1hPPWJ9emLPS66xQDe7.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3271	3342	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15Xc-pIVByVb3AU3N8jAOKJyPKBfYc56B.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3272	3343	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_10rVEdsmk2BsX6-OWMoSWqJNNrf6I6UVE.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3273	3344	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15Xc-pIVByVb3AU3N8jAOKJyPKBfYc56B.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3274	3345	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_10rVEdsmk2BsX6-OWMoSWqJNNrf6I6UVE.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3275	3346	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1jpuBrVes5JNmmIeZX_d_c8mjn2qyuBry.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3276	3347	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_dEk9kt3j15bjmqfjTm4fh4Ah-S77J-8.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3277	3348	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1TQGoIuNyLax8SiVSxYNRDJZNXEv3nCd_.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3278	3349	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1TQGoIuNyLax8SiVSxYNRDJZNXEv3nCd_.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3279	3350	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1TQGoIuNyLax8SiVSxYNRDJZNXEv3nCd_.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3280	3351	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Maf-aXMHUJ8tEkLleZWz1VF6DeIfeuz3.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3281	3375	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1x55H6CsJaXaW6xKKLidjZROyx7S9WRrv.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3282	3376	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1x55H6CsJaXaW6xKKLidjZROyx7S9WRrv.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3283	3377	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1x55H6CsJaXaW6xKKLidjZROyx7S9WRrv.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3284	3378	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1x55H6CsJaXaW6xKKLidjZROyx7S9WRrv.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3285	3379	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1x55H6CsJaXaW6xKKLidjZROyx7S9WRrv.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3286	3380	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1x55H6CsJaXaW6xKKLidjZROyx7S9WRrv.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3287	3381	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gNHLCUqEc6EKqxdmIb8YNJVzCTE1nyXy.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3288	3382	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gNHLCUqEc6EKqxdmIb8YNJVzCTE1nyXy.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3289	3383	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1VZuzVOCfDm8j9OoaRfBXDFUcwBSxA5CL.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3290	3384	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gNHLCUqEc6EKqxdmIb8YNJVzCTE1nyXy.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3291	3385	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gNHLCUqEc6EKqxdmIb8YNJVzCTE1nyXy.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3292	3386	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1VZuzVOCfDm8j9OoaRfBXDFUcwBSxA5CL.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3293	3387	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1VZuzVOCfDm8j9OoaRfBXDFUcwBSxA5CL.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3294	3388	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1yMP1eQ_zg6ldv_32NLNoeZiKyaShe_NZ.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3295	3389	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1yMP1eQ_zg6ldv_32NLNoeZiKyaShe_NZ.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3296	3390	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1B_XoQtjrtkiOZxtbM0WPSPQeyIB4glvq.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3297	3391	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1B_XoQtjrtkiOZxtbM0WPSPQeyIB4glvq.jpg	2026-03-16 23:01:57.822704+00	2026-03-16 23:01:57.822704+00
3298	3408	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1r31kw3bjyJhY-Bb_yGDFLgr2x7fX_yvf.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3299	3409	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1xsgdk8esAjvcj-M09LKP9x21qgkMp9c4.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3300	3410	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1xsgdk8esAjvcj-M09LKP9x21qgkMp9c4.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3301	3411	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1jqCScMS0XsuxvXWyhaRriV_KosrVetEY.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3302	3412	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1FsjrgRN4L8oZgDArqpaBueU3ZrZEU3Wd.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3303	3413	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Pc17SOUNTPLfhAa_D4EvviG1OQ9dGJWU.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3304	3414	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1UvNfcXkWmYK9-EqwDcSSyaSs9uXwWiMZ.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3305	3415	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AjGhbhZFOlfcjG-_M5wvgLVLJbbRzd1M.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3306	3416	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AjGhbhZFOlfcjG-_M5wvgLVLJbbRzd1M.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3307	3417	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AjGhbhZFOlfcjG-_M5wvgLVLJbbRzd1M.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3308	3418	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AjGhbhZFOlfcjG-_M5wvgLVLJbbRzd1M.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3309	3419	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bQlsyfhcdValBdbvIV8sM2bMtTNltPY1.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3310	3419	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1FBfaSCBnTjZggBZIwXrSG_C8v0Av8vJh.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3311	3419	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1TJvrCGuorT6hP_6CN5aqV_jH4Hkht75m.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3312	3420	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1bQlsyfhcdValBdbvIV8sM2bMtTNltPY1.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3313	3420	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1FBfaSCBnTjZggBZIwXrSG_C8v0Av8vJh.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3314	3420	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1TJvrCGuorT6hP_6CN5aqV_jH4Hkht75m.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3315	3421	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Zn_wZTsWDP1g8qYp081_8J1OSiTRnQ0y.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3316	3421	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gO7TaBdiJjJ7O6e7T9dOTlfdiKekXyKz.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3317	3421	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ov1rZRW3xWPAeIP8Gvm3VXj9TjJmJg2T.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3318	3422	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Zn_wZTsWDP1g8qYp081_8J1OSiTRnQ0y.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3319	3422	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gO7TaBdiJjJ7O6e7T9dOTlfdiKekXyKz.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3320	3422	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1ov1rZRW3xWPAeIP8Gvm3VXj9TjJmJg2T.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3321	3423	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_okISuE0FUjtYPVpJo4ZXYDje7QOAC9_.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3322	3424	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_okISuE0FUjtYPVpJo4ZXYDje7QOAC9_.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3323	3425	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_okISuE0FUjtYPVpJo4ZXYDje7QOAC9_.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3324	3426	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_okISuE0FUjtYPVpJo4ZXYDje7QOAC9_.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3325	3427	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_okISuE0FUjtYPVpJo4ZXYDje7QOAC9_.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3326	3428	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1_okISuE0FUjtYPVpJo4ZXYDje7QOAC9_.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3327	3429	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1dpGZtwkfp__Z0bGVaV0N7KMkz4KIsV2e.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3328	3429	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cnNODuYVO1vAaqGc_IExKbYloptILnV7.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3329	3429	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DsdU1EnXq05904x7_4oJuCzAj9w_Y8G9.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3330	3430	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1dpGZtwkfp__Z0bGVaV0N7KMkz4KIsV2e.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3331	3430	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cnNODuYVO1vAaqGc_IExKbYloptILnV7.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3332	3430	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DsdU1EnXq05904x7_4oJuCzAj9w_Y8G9.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3333	3431	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1dpGZtwkfp__Z0bGVaV0N7KMkz4KIsV2e.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3334	3431	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cnNODuYVO1vAaqGc_IExKbYloptILnV7.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3335	3431	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DsdU1EnXq05904x7_4oJuCzAj9w_Y8G9.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3336	3431	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lAtFSjGG1NwsShNT6cm88g7tIYL5Q4TS.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3337	3432	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1dpGZtwkfp__Z0bGVaV0N7KMkz4KIsV2e.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3338	3432	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cnNODuYVO1vAaqGc_IExKbYloptILnV7.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3339	3432	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DsdU1EnXq05904x7_4oJuCzAj9w_Y8G9.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3340	3432	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1lAtFSjGG1NwsShNT6cm88g7tIYL5Q4TS.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3341	3433	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_173qilAnR3kDToDnmljhUtZMCaitvTYQH.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3342	3434	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_173qilAnR3kDToDnmljhUtZMCaitvTYQH.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3343	3435	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_173qilAnR3kDToDnmljhUtZMCaitvTYQH.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3344	3435	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gBUxYkZwd2uD-SsyFgNpQqw_W4FCYei-.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3345	3436	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_173qilAnR3kDToDnmljhUtZMCaitvTYQH.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3346	3436	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gBUxYkZwd2uD-SsyFgNpQqw_W4FCYei-.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3347	3437	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1-0vmM9CT0WP1OibmTVflDNqq7sc9-0nS.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3348	3438	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1-0vmM9CT0WP1OibmTVflDNqq7sc9-0nS.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3349	3439	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1-0vmM9CT0WP1OibmTVflDNqq7sc9-0nS.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3350	3439	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gXaGqfrD-KKLzKJsTHrVgO5NKyJToE14.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3351	3440	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1-0vmM9CT0WP1OibmTVflDNqq7sc9-0nS.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3352	3440	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1gXaGqfrD-KKLzKJsTHrVgO5NKyJToE14.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3353	3441	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1akd34Rr_VYpc0p0gYBrzKrntEano-awD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3354	3442	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1akd34Rr_VYpc0p0gYBrzKrntEano-awD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3355	3443	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1akd34Rr_VYpc0p0gYBrzKrntEano-awD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3356	3443	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1y3FKizxm95Yagkpwo5a9gwOcZwQ_vuoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3357	3444	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1akd34Rr_VYpc0p0gYBrzKrntEano-awD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3358	3444	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1y3FKizxm95Yagkpwo5a9gwOcZwQ_vuoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3359	3445	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1oMdp98I5L2qfklCrzaIWdTnWh0GfOroA.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3360	3446	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1oMdp98I5L2qfklCrzaIWdTnWh0GfOroA.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3361	3447	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_16VHgnibEuRB3Hgc0xPrI2nAt6HWdUi3R.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3362	3448	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_16VHgnibEuRB3Hgc0xPrI2nAt6HWdUi3R.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3363	3449	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15DIhGDkjnyzBtg9wL3lDlRlVqThTRLcL.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3364	3450	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_15DIhGDkjnyzBtg9wL3lDlRlVqThTRLcL.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3365	3451	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1DppjPtQzJqq2rRr--z6RIZPFyfe8mhMS.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3366	3452	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uiIHsX-nwaZoypcFFStZ5i81UccY1gIF.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3367	3453	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1m6kcrOMo_Xd7vhNyueFNCJpbnDyKFHOh.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3368	3454	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cQw4fEU-lwa4YWT5RUi3UBKupsALaGha.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3369	3455	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1YL6eIoFkzAGDWbP1apzMuiIdKM72AWwr.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3370	3456	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1YL6eIoFkzAGDWbP1apzMuiIdKM72AWwr.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3371	3457	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uCmd5KtUPGysECxIBeEFK3EdjEkFlIWx.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3372	3458	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_10iO4PjG0PaeRrNSla6zPLKo2Q_ova7Ac.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3373	3459	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_10iO4PjG0PaeRrNSla6zPLKo2Q_ova7Ac.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3374	3460	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1xBTZ7Wx81El4MZ7akFqCYU_1eON46Zgb.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3375	3461	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1uCmd5KtUPGysECxIBeEFK3EdjEkFlIWx.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3376	3462	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1xBTZ7Wx81El4MZ7akFqCYU_1eON46Zgb.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3377	3463	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cZmTmNAoVwwL3V7Z4mzPsfKVh5u4KseN.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3378	3464	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cZmTmNAoVwwL3V7Z4mzPsfKVh5u4KseN.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3379	3465	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cZmTmNAoVwwL3V7Z4mzPsfKVh5u4KseN.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3380	3466	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cZmTmNAoVwwL3V7Z4mzPsfKVh5u4KseN.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3381	3467	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1cZmTmNAoVwwL3V7Z4mzPsfKVh5u4KseN.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3382	3468	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PmBByjvomJ9wUiZ28NSA51ez9IVA4-MO.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3383	3469	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PmBByjvomJ9wUiZ28NSA51ez9IVA4-MO.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3384	3470	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PmBByjvomJ9wUiZ28NSA51ez9IVA4-MO.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3385	3471	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PmBByjvomJ9wUiZ28NSA51ez9IVA4-MO.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3386	3472	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PmBByjvomJ9wUiZ28NSA51ez9IVA4-MO.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3387	3473	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PmBByjvomJ9wUiZ28NSA51ez9IVA4-MO.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3388	3474	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PmBByjvomJ9wUiZ28NSA51ez9IVA4-MO.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3389	3475	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1yIGthCvKfaH9THdaZc1mtlBv7eZ72dkZ.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3390	3476	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1yIGthCvKfaH9THdaZc1mtlBv7eZ72dkZ.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3391	3477	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1yIGthCvKfaH9THdaZc1mtlBv7eZ72dkZ.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3392	3478	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1yIGthCvKfaH9THdaZc1mtlBv7eZ72dkZ.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3393	3479	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3394	3480	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3395	3481	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3396	3482	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3397	3483	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3398	3484	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3399	3485	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3400	3486	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3401	3487	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3402	3488	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3403	3489	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3404	3490	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3405	3491	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3406	3492	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3407	3493	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_14giHf5PURDW_AmOXPoHHDNP7d9CcvfWQ.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3408	3494	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_14giHf5PURDW_AmOXPoHHDNP7d9CcvfWQ.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3409	3495	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12LFNgj--NT-k8ocAZWSxkpgy7HMy9WZc.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3410	3496	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_12LFNgj--NT-k8ocAZWSxkpgy7HMy9WZc.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3411	3497	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1nEk0CB_cjErsUT0ui4a1s1QluJovqcCE.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3412	3498	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1nEk0CB_cjErsUT0ui4a1s1QluJovqcCE.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3413	3499	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1VG1sznpRCPkjXDqRSkOoDi9GKZ53KcxM.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3414	3500	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1VG1sznpRCPkjXDqRSkOoDi9GKZ53KcxM.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3415	3501	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CBfqo11pWdu9qIzT1fMV8Z3RCxeJeuIj.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3416	3502	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1CBfqo11pWdu9qIzT1fMV8Z3RCxeJeuIj.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3417	3503	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1KLW8-qOqy1HoX4yyRFz2X1h8gTW1Xggz.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3418	3504	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1KLW8-qOqy1HoX4yyRFz2X1h8gTW1Xggz.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3419	3505	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1mk-i2Tu5jNhiyGE1_BGRCb7R_0gm7MBK.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3420	3506	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1mk-i2Tu5jNhiyGE1_BGRCb7R_0gm7MBK.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3421	3507	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1iXkzp4iMYunZHSMee-4d_tkwXr_5vy_r.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3422	3508	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1iXkzp4iMYunZHSMee-4d_tkwXr_5vy_r.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3423	3509	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1AC8yKqsrMzo76f8mPWNO7JSbzJEV-MNg.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3424	3510	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1e9KnVAXH6_ieOtFuRhxagIQFynfgiYDO.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3425	3511	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1O4z-VK-P0UQrz27E6APb6XIrXFCjFCd6.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3426	3512	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1iE0pYGV1PZH4WsaHbC-qH2chsccn_SPY.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3427	3513	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1PTEsh8nPay2t35xFgwMMtro6KN2FjCeH.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3428	3514	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_18MnErn3GKQJ5SyOrj0DCWqhW-IHBYtIG.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3429	3515	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1qYjYOHEYKACltCfyxaavvXVPxHP5ujIS.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3430	3516	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1MH4BuGqZgxlAB_dTApmymHVykkimCUtF.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3431	3517	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1MH4BuGqZgxlAB_dTApmymHVykkimCUtF.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3432	3518	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1MH4BuGqZgxlAB_dTApmymHVykkimCUtF.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3433	3519	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1E-8RW9gRBF0dsckNnMXAc0SgWWqxShDl.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3434	3520	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1Lvn4Wh-WKAJYkKnkHLYXFt01VhtHraSt.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
3435	3521	https://zpcnvcthecltyiopstxd.supabase.co/storage/v1/object/public/products/produtos/shared/drive_1E-8RW9gRBF0dsckNnMXAc0SgWWqxShDl.jpg	2026-03-16 23:10:10.170341+00	2026-03-16 23:10:10.170341+00
\.


--
-- Data for Name: itens_pedido; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.itens_pedido (id_item, id_pedido, id_produto, quantidade, preco_unitario, subtotal, created_at, updated_at) FROM stdin;
1	1	2905	4	113.99	455.96	2025-12-17 13:52:38.979073+00	2025-12-17 13:52:38.979073+00
2	2	3014	1	236.48	236.48	2026-01-23 18:52:40.564317+00	2026-01-23 18:52:40.564317+00
3	2	3154	3	27.68	83.04	2026-01-23 18:52:40.564317+00	2026-01-23 18:52:40.564317+00
4	3	3059	1	111.74	111.74	2026-01-29 20:17:57.149558+00	2026-01-29 20:17:57.149558+00
5	3	3058	4	19.82	79.28	2026-01-29 20:17:57.149558+00	2026-01-29 20:17:57.149558+00
6	3	3457	1	14.82	14.82	2026-01-29 20:17:57.149558+00	2026-01-29 20:17:57.149558+00
7	4	3454	4	6.07	24.28	2026-01-29 20:35:52.350761+00	2026-01-29 20:35:52.350761+00
8	4	3352	1	16.61	16.61	2026-01-29 20:35:52.350761+00	2026-01-29 20:35:52.350761+00
9	4	3353	1	93.70	93.70	2026-01-29 20:35:52.350761+00	2026-01-29 20:35:52.350761+00
10	5	3014	1	236.48	236.48	2026-01-29 20:37:02.806284+00	2026-01-29 20:37:02.806284+00
11	5	3013	1	41.93	41.93	2026-01-29 20:37:02.806284+00	2026-01-29 20:37:02.806284+00
12	6	3388	1	134.45	134.45	2026-02-03 20:05:51.146252+00	2026-02-03 20:05:51.146252+00
13	7	3449	8	21.72	173.76	2026-02-09 00:51:10.331337+00	2026-02-09 00:51:10.331337+00
14	8	2905	1	125.22	125.22	2026-02-10 18:24:44.937852+00	2026-02-10 18:24:44.937852+00
15	8	2911	1	145.43	145.43	2026-02-10 18:24:44.937852+00	2026-02-10 18:24:44.937852+00
16	8	2903	1	680.82	680.82	2026-02-10 18:24:44.937852+00	2026-02-10 18:24:44.937852+00
17	9	2914	1	45.74	45.74	2026-02-10 18:27:55.509121+00	2026-02-10 18:27:55.509121+00
18	9	2918	1	51.22	51.22	2026-02-10 18:27:55.509121+00	2026-02-10 18:27:55.509121+00
19	10	3011	5	1.14	5.70	2026-02-10 19:21:14.645243+00	2026-02-10 19:21:14.645243+00
20	10	3012	1	1.36	1.36	2026-02-10 19:21:14.645243+00	2026-02-10 19:21:14.645243+00
21	10	2993	1	3.40	3.40	2026-02-10 19:21:14.645243+00	2026-02-10 19:21:14.645243+00
22	10	3080	1	18.38	18.38	2026-02-10 19:21:14.645243+00	2026-02-10 19:21:14.645243+00
23	10	3058	1	18.04	18.04	2026-02-10 19:21:14.645243+00	2026-02-10 19:21:14.645243+00
24	10	3073	2	200.80	401.60	2026-02-10 19:21:14.645243+00	2026-02-10 19:21:14.645243+00
25	10	3022	2	237.42	474.84	2026-02-10 19:21:14.645243+00	2026-02-10 19:21:14.645243+00
26	11	3011	2	1.14	2.28	2026-03-25 11:19:20.327329+00	2026-03-25 11:19:20.327329+00
27	11	3004	2	2.81	5.62	2026-03-25 11:19:20.327329+00	2026-03-25 11:19:20.327329+00
28	11	2999	4	4.94	19.76	2026-03-25 11:19:20.327329+00	2026-03-25 11:19:20.327329+00
29	11	2920	1	532.62	532.62	2026-03-25 11:19:20.327329+00	2026-03-25 11:19:20.327329+00
30	11	2930	2	48.50	97.00	2026-03-25 11:19:20.327329+00	2026-03-25 11:19:20.327329+00
31	11	2961	2	327.56	655.12	2026-03-25 11:19:20.327329+00	2026-03-25 11:19:20.327329+00
32	11	2912	1	798.03	798.03	2026-03-25 11:19:20.327329+00	2026-03-25 11:19:20.327329+00
33	12	3361	2	50.74	101.48	2026-03-25 11:21:32.474618+00	2026-03-25 11:21:32.474618+00
34	12	3416	3	31.28	93.84	2026-03-25 11:21:32.474618+00	2026-03-25 11:21:32.474618+00
35	12	3336	2	65.29	130.58	2026-03-25 11:21:32.474618+00	2026-03-25 11:21:32.474618+00
36	12	3347	5	12.01	60.05	2026-03-25 11:21:32.474618+00	2026-03-25 11:21:32.474618+00
37	12	3516	1	2555.59	2555.59	2026-03-25 11:21:32.474618+00	2026-03-25 11:21:32.474618+00
38	12	3521	1	567.33	567.33	2026-03-25 11:21:32.474618+00	2026-03-25 11:21:32.474618+00
39	12	3479	3	2.77	8.31	2026-03-25 11:21:32.474618+00	2026-03-25 11:21:32.474618+00
40	13	2959	1	1414.35	1414.35	2026-03-25 11:24:24.9211+00	2026-03-25 11:24:24.9211+00
41	13	2925	1	1165.10	1165.10	2026-03-25 11:24:24.9211+00	2026-03-25 11:24:24.9211+00
42	13	3494	1	465.82	465.82	2026-03-25 11:24:24.9211+00	2026-03-25 11:24:24.9211+00
43	13	3501	1	179.19	179.19	2026-03-25 11:24:24.9211+00	2026-03-25 11:24:24.9211+00
44	13	3510	1	211.95	211.95	2026-03-25 11:24:24.9211+00	2026-03-25 11:24:24.9211+00
45	14	3375	3	16.49	49.47	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
46	14	3432	1	161.49	161.49	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
47	14	3029	1	75.75	75.75	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
48	14	3026	1	333.61	333.61	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
49	14	3078	5	77.43	387.15	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
50	14	3135	4	47.95	191.80	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
51	14	3195	2	204.38	408.76	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
52	14	3442	2	420.12	840.24	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
53	15	3375	3	16.49	49.47	2026-04-09 22:49:45.633727+00	2026-04-09 22:49:45.633727+00
54	15	3432	1	161.49	161.49	2026-04-09 22:49:45.633727+00	2026-04-09 22:49:45.633727+00
55	15	3029	1	75.75	75.75	2026-04-09 22:49:45.633727+00	2026-04-09 22:49:45.633727+00
56	15	3026	1	333.61	333.61	2026-04-09 22:49:45.633727+00	2026-04-09 22:49:45.633727+00
57	15	3135	7	47.95	335.65	2026-04-09 22:49:45.633727+00	2026-04-09 22:49:45.633727+00
58	16	3375	6	16.49	98.94	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
59	16	3432	2	161.49	322.98	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
60	16	3078	6	77.43	464.58	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
61	16	3416	5	30.17	150.85	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
62	16	3342	3	60.69	182.07	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
63	16	3350	6	6.74	40.44	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
64	16	3516	2	2464.54	4929.08	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
65	16	3521	2	547.12	1094.24	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
66	16	3501	3	163.12	489.36	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
\.


--
-- Data for Name: pedidos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.pedidos (id_pedido, id_cliente, id_cupom, status, valor_total, created_at, updated_at) FROM stdin;
1	13	\N	PENDENTE	455.96	2025-12-17 13:52:38.979073+00	2025-12-17 13:52:38.979073+00
2	13	\N	PENDENTE	319.52	2026-01-23 18:52:40.564317+00	2026-01-23 18:52:40.564317+00
3	14	\N	PENDENTE	205.84	2026-01-29 20:17:57.149558+00	2026-01-29 20:17:57.149558+00
4	14	\N	PENDENTE	134.59	2026-01-29 20:35:52.350761+00	2026-01-29 20:35:52.350761+00
5	14	\N	PENDENTE	278.41	2026-01-29 20:37:02.806284+00	2026-01-29 20:37:02.806284+00
6	13	\N	PENDENTE	134.45	2026-02-03 20:05:51.146252+00	2026-02-03 20:05:51.146252+00
7	14	\N	PENDENTE	173.76	2026-02-09 00:51:10.331337+00	2026-02-09 00:51:10.331337+00
8	15	\N	PENDENTE	951.47	2026-02-10 18:24:44.937852+00	2026-02-10 18:24:44.937852+00
9	15	\N	PENDENTE	96.96	2026-02-10 18:27:55.509121+00	2026-02-10 18:27:55.509121+00
10	15	\N	PENDENTE	923.32	2026-02-10 19:21:14.645243+00	2026-02-10 19:21:14.645243+00
11	13	\N	PENDENTE	2110.43	2026-03-25 11:19:20.327329+00	2026-03-25 11:19:20.327329+00
12	13	\N	PENDENTE	3517.18	2026-03-25 11:21:32.474618+00	2026-03-25 11:21:32.474618+00
13	13	\N	PENDENTE	3436.41	2026-03-25 11:24:24.9211+00	2026-03-25 11:24:24.9211+00
14	13	\N	PENDENTE	2448.27	2026-03-25 11:35:00.736342+00	2026-03-25 11:35:00.736342+00
15	13	\N	PENDENTE	1018.11	2026-04-09 22:49:45.633727+00	2026-04-09 22:49:45.633727+00
16	13	\N	PENDENTE	8277.76	2026-04-15 17:51:12.509089+00	2026-04-15 17:51:12.509089+00
\.


--
-- Data for Name: precos_produto; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.precos_produto (id_preco, id_produto, id_regiao, preco_0, preco_30, preco_60, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: produtos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.produtos (id_produto, codigo, nome, quantidade, descricao, cod_kit, id_categoria, id_subcategoria, valor_base, ativo, created_at, updated_at) FROM stdin;
3024	4770	CACAROLA NEW FORT FLON 18 - TPA VIDRO	6	6 peças	5201	2	8	53.78	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3026	4771	CACAROLA NEW FORT FLON 20 - TPA VIDRO	6	6 peças	5202	2	8	63.40	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3028	4772	CACAROLA NEW FORT FLON 22 - TPA VIDRO	6	6 peças	5203	2	8	71.56	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3030	4773	CACAROLA NEW FORT FLON 24 - TPA VIDRO	6	6 peças	5204	2	8	81.19	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3059	4685	PANELA REFORÇADA POLIDA 14	6	6 peças	3033	2	12	19.33	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3061	4686	PANELA REFORÇADA POLIDA 16	6	6 peças	3034	2	12	30.35	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3063	4687	PANELA REFORÇADA POLIDA 18	6	6 peças	3035	2	12	35.43	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3065	4688	PANELA REFORÇADA POLIDA 20	6	6 peças	3036	2	12	42.61	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3067	4689	PANELA REFORÇADA POLIDA 22	6	6 peças	3037	2	12	50.22	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3069	4690	CACAROLA REFORÇADA POLIDA 24	6	6 peças	3038	2	12	59.63	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3071	4691	CACAROLA REFORÇADA POLIDA 16	6	6 peças	3168	2	12	33.38	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3073	4692	CACAROLA REFORÇADA POLIDA 18	6	6 peças	3170	2	12	38.16	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3075	4693	CACAROLA REFORÇADA POLIDA 20	6	6 peças	3171	2	12	44.28	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3077	4694	CACAROLA REFORÇADA POLIDA 20	6	6 peças	3172	2	12	51.53	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3436	4577	CONJUNTO MULTIUSO REFORÇADO POLIDO 20 C/ CAIXA	3	3 peças	4085	17	\N	66.02	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3439	4553	VAPOLAR REFORÇADO POLIDO 20 C/ CAIXA	3	3 peças	4046	17	\N	64.79	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3440	4760	VAPOLAR REFORÇADO POLIDO 20 C/ CAIXA	6	6 peças	3158	17	\N	65.69	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3442	4755	PIPOQUEIRA REFORÇADA POLIDA 20	6	6 peças	3139	18	\N	79.84	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3444	4545	PIPOQUEIRA REFORÇADA POLIDA 20 C/ CAIXA	3	3 peças	4017	18	\N	64.58	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3446	4756	PIPOQUEIRA REFORÇADA POLIDA 20	6	6 peças	7154	18	\N	49.38	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3448	4757	MORINGA REFORÇADA POLIDA 02	6	6 peças	3101	19	\N	26.05	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3450	4761	GUARDA OLEO REFORÇADO POLIDO C/ PENEIRA 11	6	6 peças	3157	20	\N	21.20	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3494	4538	CONJUNTO PANELEIRO PRATIK LAR 5 PCS	4	4 peças	4008	24	46	120.88	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3496	4539	CONJUNTO PANELEIRO PRATIK FLON 5 PCS	4	4 peças	4009	24	46	153.79	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3498	4529	CONJUNTO PANELEIRO CLASSIC 6 PCS C/ PP	3	3 peças	4018	24	46	212.22	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3500	4535	CONJUNTO PANELEIRO FORT FLON 6 PCS C/ PP	3	3 peças	4034	24	46	189.37	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3502	4532	CONJUNTO PANELEIRO PLATINUM 7 PCS C/ PP	2	2 peças	4048	24	46	171.48	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3504	4533	CONJUNTO PANELEIRO PLATINUM 9 PCS C/ PP	2	2 peças	4049	24	46	207.26	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3506	4536	CONJUNTO PANELEIRO FORT FLON 7 PCS C/ PP	2	2 peças	4050	24	46	227.26	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3508	4537	CONJUNTO PANELEIRO FORT FLON 9 PCS C/ PP	2	2 peças	4051	24	46	300.94	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3014	4774	PANELA NEW FORT FLON 16 - TPA VIDRO	6	6 peças	5205	2	8	40.91	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3016	4775	PANELA NEW FORT FLON 18 - TPA VIDRO	6	6 peças	5206	2	8	49.82	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3018	4776	PANELA NEW FORT FLON 20 - TPA VIDRO	6	6 peças	5207	2	8	57.62	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3020	4777	PANELA NEW FORT FLON 22 - TPA VIDRO	6	6 peças	5208	2	8	65.61	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3022	4769	CACAROLA NEW FORT FLON 16 - TPA VIDRO	6	6 peças	5200	2	8	45.12	t	2025-12-16 22:56:38.984802+00	2026-03-16 22:30:57.212625+00
3091	4778	CALDEIRAO NEW FORT FLON 16 - TPA VIDRO	6	6 peças	5209	3	14	52.90	t	2025-12-16 22:59:31.486933+00	2026-03-16 22:39:21.06483+00
3093	4779	CALDEIRAO NEW FORT FLON 18 - TPA VIDRO	6	6 peças	5210	3	14	61.24	t	2025-12-16 22:59:31.486933+00	2026-03-16 22:39:21.06483+00
3006	9031	HASTE DE METAL CABO TPA PP 10,0 L	1	- 10,00 L	\N	1	7	8.05	t	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
3007	9086	HASTE DE METAL CABO TPA PP 2,5 L	1	- 2,50 L	\N	1	7	5.80	t	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
3008	9087	HASTE DE METAL CABO TPA PP 3,0  L	1	- 3,00  L	\N	1	7	5.80	t	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
3009	9017	HASTE DE METAL CABO TPA PP 4,5 L	1	- 4,50 L	\N	1	7	6.41	t	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
3010	9018	HASTE DE METAL CABO TPA PP 7,0 L	1	- 7,00 L	\N	1	7	6.56	t	2025-12-16 22:43:56.284741+00	2025-12-16 22:43:56.284741+00
3013	5205	PANELA NEW FORT FLON 16 - TPA VIDRO	1	- 1,10 L	\N	2	8	43.52	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3015	5206	PANELA NEW FORT FLON 18 - TPA VIDRO	1	- 1,60 L	\N	2	8	53.00	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3017	5207	PANELA NEW FORT FLON 20 - TPA VIDRO	1	- 2,30 L	\N	2	8	61.30	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3019	5208	PANELA NEW FORT FLON 22 - TPA VIDRO	1	- 3,00 L	\N	2	8	69.80	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3021	5200	CACAROLA NEW FORT FLON 16 - TPA VIDRO	1	- 1,10 L	\N	2	8	48.00	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3023	5201	CACAROLA NEW FORT FLON 18 - TPA VIDRO	1	- 1,60 L	\N	2	8	57.22	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3025	5202	CACAROLA NEW FORT FLON 20 - TPA VIDRO	1	- 2,30 L	\N	2	8	67.45	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3027	5203	CACAROLA NEW FORT FLON 22 - TPA VIDRO	1	- 3,00 L	\N	2	8	76.13	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3029	5204	CACAROLA NEW FORT FLON 24 - TPA VIDRO	1	- 4,10 L	\N	2	8	86.37	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3031	5029	PANELA SUPER FORT FLON GRAFITE 16 - TPA VIDRO	1	- 1,50 L	\N	2	9	70.55	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3032	5030	PANELA SUPER FORT FLON GRAFITE 18 - TPA VIDRO	1	- 2,00 L	\N	2	9	85.09	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3033	5031	PANELA SUPER FORT FLON GRAFITE 20 - TPA VIDRO	1	- 2,70 L	\N	2	9	102.54	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3034	5032	PANELA SUPER FORT FLON GRAFITE 22 - TPA VIDRO	1	- 3,50 L	\N	2	9	122.26	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3035	5033	CACAROLA SUPER FORT FLON GRAFITE 16 - TPA VIDRO	1	- 1,50 L	\N	2	9	73.05	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3036	5034	CACAROLA SUPER FORT FLON GRAFITE 18 - TPA VIDRO	1	- 2,00 L	\N	2	9	87.71	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3037	5035	CACAROLA SUPER FORT FLON GRAFITE 20 - TPA VIDRO	1	- 2,70 L	\N	2	9	104.23	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3038	5036	CACAROLA SUPER FORT FLON GRAFITE 22 - TPA VIDRO	1	- 3,50 L	\N	2	9	123.85	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3039	5037	CACAROLA SUPER FORT FLON GRAFITE 24 - TPA VIDRO	1	- 4,20 L	\N	2	9	147.22	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3040	1001	PANELA SUPER FORTE POLIDA 16	1	- 1,70 L	\N	2	10	54.08	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3041	1002	PANELA SUPER FORTE POLIDA 18	1	- 2,30 L	\N	2	10	66.02	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3042	1003	PANELA SUPER FORTE POLIDA 20	1	- 3,30 L	\N	2	10	80.88	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3043	1004	PANELA SUPER FORTE POLIDA 22	1	- 4,15 L	\N	2	10	93.24	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3044	1005	CACAROLA SUPER FORTE POLIDA 24	1	- 5,25 L	\N	2	10	117.80	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3045	1006	CACAROLA SUPER FORTE POLIDA 16	1	- 1,70 L	\N	2	10	57.88	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3046	1007	CACAROLA SUPER FORTE POLIDA 18	1	- 2,30 L	\N	2	10	69.83	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3047	1008	CACAROLA SUPER FORTE POLIDA 20	1	- 3,30 L	\N	2	10	86.24	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3048	1009	CACAROLA SUPER FORTE POLIDA 22	1	- 4,15 L	\N	2	10	98.66	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3049	2001	PANELA EXTRA FORTE POLIDA 16	1	- 1,55 L	\N	2	11	40.93	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3050	2002	PANELA EXTRA FORTE POLIDA 18	1	- 2,10 L	\N	2	11	49.62	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3051	2003	PANELA EXTRA FORTE POLIDA 20	1	- 2,80 L	\N	2	11	58.53	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3052	2004	PANELA EXTRA FORTE POLIDA 22	1	- 3,60 L	\N	2	11	70.48	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3053	2005	CACAROLA EXTRA FORTE POLIDA 24	1	- 4,40 L	\N	2	11	85.16	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3054	2029	CACAROLA EXTRA FORTE POLIDA 16	1	- 1,55 L	\N	2	11	44.50	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3055	2030	CACAROLA EXTRA FORTE POLIDA 18	1	- 2,10 L	\N	2	11	54.68	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3056	2031	CACAROLA EXTRA FORTE POLIDA 20	1	- 2,80 L	\N	2	11	61.11	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3057	2032	CACAROLA EXTRA FORTE POLIDA 22	1	- 3,60 L	\N	2	11	72.74	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3058	3033	PANELA REFORÇADA POLIDA 14	1	- 1,00 L	\N	2	12	20.57	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3060	3034	PANELA REFORÇADA POLIDA 16	1	- 1,35 L	\N	2	12	32.29	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3062	3035	PANELA REFORÇADA POLIDA 18	1	- 1,80 L	\N	2	12	37.69	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3064	3036	PANELA REFORÇADA POLIDA 20	1	- 2,50 L	\N	2	12	45.33	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3066	3037	PANELA REFORÇADA POLIDA 22	1	- 3,30 L	\N	2	12	53.42	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3068	3038	CACAROLA REFORÇADA POLIDA 24	1	- 4,50 L	\N	2	12	63.44	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3072	3170	CACAROLA REFORÇADA POLIDA 18	1	- 1,80 L	\N	2	12	40.60	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3074	3171	CACAROLA REFORÇADA POLIDA 20	1	- 2,50 L	\N	2	12	47.11	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3076	3172	CACAROLA REFORÇADA POLIDA 22	1	- 3,30 L	\N	2	12	54.82	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3078	3195	FRITA FACIL REFORÇADO POLIDA C/ PENEIRA 20	1	- 2,50 L	\N	2	12	88.29	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3079	3039	PAPEIRO REFORÇADA POLIDA 14	1	- 1,00 L	\N	2	12	17.93	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3080	3040	PAPEIRO REFORÇADA POLIDA 16	1	- 1,60 L	\N	2	12	20.96	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3081	3041	PAPEIRO REFORÇADA POLIDA 18	1	- 1,95 L	\N	2	12	26.32	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3083	6024	CACAROLA EXTRA FORTE ACETINADA 30	1	- 10,50 L	\N	2	13	168.11	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3084	6025	CACAROLA EXTRA FORTE ACETINADA 36	1	- 19,00 L	\N	2	13	244.16	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3085	6026	CACAROLA EXTRA FORTE ACETINADA 40	1	- 26,00 L	\N	2	13	301.89	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3086	6027	CACAROLA EXTRA FORTE ACETINADA 45	1	- 38,00 L	\N	2	13	373.48	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3082	3048	PAPEIRO REFORÇADA POLIDA 12	1	- 0,70 L	\N	2	12	15.96	t	2025-12-16 22:56:38.984802+00	2026-03-25 13:36:42.778047+00
3070	3168	CACAROLA REFORÇADA POLIDA 16	1	- 1,35 L	\N	2	12	35.51	t	2025-12-16 22:56:38.984802+00	2026-04-23 23:38:51.479353+00
3087	6028	CACAROLA REFORÇADA ACETINADA 30	1	- 10,50 L	\N	2	13	133.65	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3088	6029	CACAROLA REFORÇADA ACETINADA 36	1	- 19,00 L	\N	2	13	189.27	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3089	6030	CACAROLA REFORÇADA ACETINADA 40	1	- 26,00 L	\N	2	13	221.07	t	2025-12-16 22:56:38.984802+00	2025-12-16 22:56:38.984802+00
3090	5209	CALDEIRAO NEW FORT FLON 16 - TPA VIDRO	1	- 1,75 L	\N	3	14	56.27	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3092	5210	CALDEIRAO NEW FORT FLON 18 - TPA VIDRO	1	- 2,30 L	\N	3	14	65.15	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3094	2009	CALDEIRAO EXTRA FORTE POLIDO 16	1	- 2,00 L	\N	3	15	50.85	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3095	2010	CALDEIRAO EXTRA FORTE POLIDO 18	1	- 2,80 L	\N	3	15	59.70	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3096	3238	CALDEIRAO REFORÇADO POLIDO 16	1	- 2,00 L	\N	3	16	39.50	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3097	3045	CALDEIRAO BOJUDO REFORÇADO FOSCO 10	1	- 1,00 L	\N	3	16	15.38	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3098	3046	CALDEIRAO BOJUDO REFORÇADO FOSCO 12	1	- 1,55 L	\N	3	16	19.81	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3099	3047	CALDEIRAO BOJUDO REFORÇADO FOSCO 14	1	- 2,25 L	\N	3	16	24.41	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3100	6031	CALDEIRAO EXTRA FORTE ACETINADO 30	1	- 21,00 L	\N	3	17	231.32	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3101	6032	CALDEIRAO EXTRA FORTE ACETINADO 36	1	- 35,00 L	\N	3	17	316.68	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3102	6033	CALDEIRAO EXTRA FORTE ACETINADO 40	1	- 49,00 L	\N	3	17	410.71	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3103	6034	CALDEIRAO EXTRA FORTE ACETINADO 45	1	- 74,00 L	\N	3	17	494.88	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3104	6035	CALDEIRAO REFORÇADO ACETINADO 30	1	- 21,00 L	\N	3	17	182.15	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3105	6036	CALDEIRAO REFORÇADO ACETINADO 36	1	- 35,00 L	\N	3	17	248.34	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3106	6037	CALDEIRAO REFORÇADO ACETINADO 40	1	- 49,00 L	\N	3	17	313.72	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3107	6038	CALDEIRAO REFORÇADO ACETINADO 26	1	- 13,00 L	\N	3	17	135.79	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3108	6039	CALDEIRAO REFORÇADO ACETINADO 28	1	- 16,50 L	\N	3	17	146.52	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3109	6040	CALDEIRAO EXTRA FORTE ACETINADO 26	1	- 13,00 L	\N	3	17	177.90	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3110	6041	CALDEIRAO EXTRA FORTE ACETINADO 28	1	- 16,50 L	\N	3	17	192.95	t	2025-12-16 22:59:31.486933+00	2025-12-16 22:59:31.486933+00
3111	5211	CANECAO NEW FORT FLON 12	1	- 1,10 L	\N	4	18	26.56	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3113	5212	CANECAO NEW FORT FLON 14	1	- 1,55 L	\N	4	18	32.48	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3115	5213	CANECAO NEW FORT FLON 16	1	- 2,20 L	\N	4	18	44.13	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3117	5214	FERVEDOR NEW FORT FLON C/ TPA VIDRO 12	1	- 1,05 L	\N	4	18	41.47	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3119	5215	FERVEDOR NEW FORT FLON C/ TPA VIDRO 14	1	- 1,55 L	\N	4	18	47.32	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3121	5216	FERVEDOR NEW FORT FLON C/ TPA VIDRO 16	1	- 2,20 L	\N	4	18	59.62	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3123	2033	CANECAO EXTRA FORTE POLIDO 10	1	- 1,00 L	\N	4	19	19.48	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3124	2016	CANECAO EXTRA FORTE POLIDO 12	1	- 1,30 L	\N	4	19	26.89	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3125	2017	CANECAO EXTRA FORTE POLIDO 14	1	- 1,90 L	\N	4	19	31.84	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3126	2018	CANECAO EXTRA FORTE POLIDO 16	1	- 2,55 L	\N	4	19	42.23	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3127	2054	CANECAO EXTRA FORTE POLIDO 18	1	- 4,00 L	\N	4	19	65.08	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3128	2020	FERVEDOR EXTRA FORTE POLIDO 12	1	- 1,10 L	\N	4	19	33.19	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3129	2021	FERVEDOR EXTRA FORTE POLIDO 14	1	- 1,70 L	\N	4	19	39.52	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3130	2022	FERVEDOR EXTRA FORTE POLIDO 16	1	- 2,35 L	\N	4	19	51.83	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3131	2049	CANECAO EXTRA FORTE POLIDO C/ CABO MAD 10	1	- 1,00 L	\N	4	19	25.48	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3132	2050	CANECAO EXTRA FORTE POLIDO C/ CABO MAD 12	1	- 1,30 L	\N	4	19	31.97	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3133	2051	CANECAO EXTRA FORTE POLIDO C/ CABO MAD 14	1	- 1,90 L	\N	4	19	37.33	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3134	2052	CANECAO EXTRA FORTE POLIDO C/ CABO MAD 16	1	- 2,55 L	\N	4	19	47.69	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3135	2019	CANECAO EXTRA FORTE POLIDO C/ CABO MAD 18	1	- 4,00 L	\N	4	19	54.68	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3136	3049	CANECAO REFORÇADO POLIDO 10	1	- 1,00 L	\N	4	20	16.03	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3138	3061	CANECAO REFORÇADO POLIDO 12	1	- 1,30 L	\N	4	20	18.02	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3140	3062	CANECAO REFORÇADO POLIDO 14	1	- 1,90 L	\N	4	20	22.53	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3142	3063	CANECAO REFORÇADO POLIDO 16	1	- 2,55 L	\N	4	20	27.42	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3144	3044	CANECAO REFORÇADO POLIDO 18	1	- 3,85 L	\N	4	20	50.29	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3146	3081	FERVEDOR REFORÇADO POLIDO 12	1	- 1,10 L	\N	4	20	24.43	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3148	3082	FERVEDOR REFORÇADO POLIDO 14	1	- 1,70 L	\N	4	20	29.83	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3112	4780	CANECAO NEW FORT FLON 12	6	6 peças	5211	4	18	24.96	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3114	4781	CANECAO NEW FORT FLON 14	6	6 peças	5212	4	18	30.53	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3150	3083	FERVEDOR REFORÇADO POLIDO 16	1	- 2,35 L	\N	4	20	37.17	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3152	3218	CANECAO REFORÇADO POLIDO C/ CABO MADEIRA 12	1	- 1,30 L	\N	4	20	24.30	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3154	3219	CANECAO REFORÇADO POLIDO C/ CABO MADEIRA 14	1	- 1,90 L	\N	4	20	28.73	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3156	3220	CANECAO REFORÇADO POLIDO C/ CABO MADEIRA 16	1	- 2,55 L	\N	4	20	33.90	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3158	3064	CANECAO REFORÇADO POLIDO C/ CABO MADEIRA 18	1	- 3,85 L	\N	4	20	40.35	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3160	6015	CANECAO EXTRA ACETINADO 20	1	- 5,50 L	\N	4	21	76.47	t	2025-12-16 23:02:44.18885+00	2025-12-16 23:02:44.18885+00
3164	5226	FRIG FRANCESA NEW FORT FLON 16	1	- 0,60 L	\N	5	23	22.31	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3166	5227	FRIG FRANCESA NEW FORT FLON 18	1	- 0,75 L	\N	5	23	26.09	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3168	5228	FRIG FRANCESA NEW FORT FLON 20	1	- 0,85 L	\N	5	23	28.49	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3170	5229	FRIG FRANCESA NEW FORT FLON 22	1	- 1,00 L	\N	5	23	33.92	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3172	5230	FRIG FRANCESA NEW FORT FLON 24	1	- 1,15 L	\N	5	23	38.41	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3174	5231	FRIG FRANCESA NEW FORT FLON 26	1	- 1,65 L	\N	5	23	45.41	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3176	5221	FRIG NEW FORT FLON 18 - TPA VIDRO	1	- 0,90 L	\N	5	23	44.65	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3178	5222	FRIG NEW FORT FLON 20 - TPA VIDRO	1	- 1,15 L	\N	5	23	51.45	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3180	5223	FRIG NEW FORT FLON 22 - TPA VIDRO	1	- 1,65 L	\N	5	23	58.37	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3182	5224	FRIG NEW FORT FLON 24 - TPA VIDRO	1	- 1,95 L	\N	5	23	65.62	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3184	5217	FRIG NEW FORT FLON S/ TPA 18	1	- 0,90 L	\N	5	23	29.19	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3186	5218	FRIG NEW FORT FLON S/ TPA 20	1	- 1,15 L	\N	5	23	34.70	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3188	5219	FRIG NEW FORT FLON S/ TPA 22	1	- 1,65 L	\N	5	23	40.58	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3190	5220	FRIG NEW FORT FLON S/ TPA 24	1	- 1,95 L	\N	5	23	45.51	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3192	5079	BISTEQUEIRA CANELADA QUADRADA FORT FLON	1	- 28,5 X 26,5 X 2,4 CM	\N	5	23	99.44	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3194	5103	CREPEIRA / PANQUEQUEIRA FORT FLON 20	1	- 0,60 L	\N	5	23	41.32	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3196	5076	CREPEIRA / PANQUEQUEIRA FORT FLON 22	1	- 0,70 L	\N	5	23	48.57	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3198	5040	OMELETEIRA FORT FLON 18	1	- 0,70 L	\N	5	23	61.77	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3199	5101	OMELETEIRA FORT FLON 20	1	- 1,10 L	\N	5	23	74.19	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3201	5102	OMELETEIRA FORT FLON 22	1	- 1,50 L	\N	5	23	83.14	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3203	5120	FRIG SUPER FORT FLON GRAFITE S/ TPA 20	1	- 1,80 L	\N	5	24	60.70	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3204	5121	FRIG SUPER FORT FLON GRAFITE S/ TPA 22	1	- 2,50 L	\N	5	24	75.38	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3205	5122	FRIG SUPER FORT FLON GRAFITE S/ TPA 24	1	- 3,00 L	\N	5	24	89.89	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3206	5123	FRIG SUPER FORT FLON GRAFITE C/ TPA VIDRO 20	1	- 1,80 L	\N	5	24	74.73	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3207	5124	FRIG SUPER FORT FLON GRAFITE C/ TPA VIDRO 22	1	- 2,50 L	\N	5	24	89.28	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3208	5125	FRIG SUPER FORT FLON GRAFITE C/ TPA VIDRO 24	1	- 3,00 L	\N	5	24	106.57	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3209	1024	FRIG SUPER FORTE POLIDA S/ TPA 20	1	- 1,60 L	\N	5	25	48.45	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3210	1025	FRIG SUPER FORTE POLIDA S/ TPA 22	1	- 1,90 L	\N	5	25	59.87	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3211	1028	FRIG SUPER FORTE POLIDA S/ TPA 24	1	- 2,70 L	\N	5	25	71.11	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3212	1026	FRIG SUPER FORTE POLIDA C/ TPA 20	1	- 1,60 L	\N	5	25	65.57	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3165	4794	FRIG FRANCESA NEW FORT FLON 16	6	6 peças	5226	5	23	20.97	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3167	4795	FRIG FRANCESA NEW FORT FLON 18	6	6 peças	5227	5	23	24.52	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3169	4796	FRIG FRANCESA NEW FORT FLON 20	6	6 peças	5228	5	23	26.78	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3171	4797	FRIG FRANCESA NEW FORT FLON 22	6	6 peças	5229	5	23	31.89	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3173	4798	FRIG FRANCESA NEW FORT FLON 24	6	6 peças	5230	5	23	36.11	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3175	4799	FRIG FRANCESA NEW FORT FLON 26	6	6 peças	5231	5	23	42.69	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3177	4790	FRIG NEW FORT FLON 18 - TPA VIDRO	6	6 peças	5221	5	23	41.97	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3179	4791	FRIG NEW FORT FLON 20 - TPA VIDRO	6	6 peças	5222	5	23	48.36	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3213	1027	FRIG SUPER FORTE POLIDA C/ TPA 22	1	- 1,90 L	\N	5	25	78.26	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3214	1029	FRIG SUPER FORTE POLIDA C/ TPA 24	1	- 2,70 L	\N	5	25	92.57	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3215	2023	FRIG EXTRA FORTE POLIDA S/ TPA 20	1	- 1,60 L	\N	5	26	33.26	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3216	2024	FRIG EXTRA FORTE POLIDA S/ TPA 22	1	- 1,90 L	\N	5	26	37.78	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3217	2025	FRIG EXTRA FORTE POLIDA S/ TPA 24	1	- 2,70 L	\N	5	26	44.24	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3218	2026	FRIG EXTRA FORTE POLIDA C/ TPA 20	1	- 1,60 L	\N	5	26	49.42	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3219	2027	FRIG EXTRA FORTE POLIDA C/ TPA 22	1	- 1,90 L	\N	5	26	56.08	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3220	2028	FRIG EXTRA FORTE POLIDA C/ TPA 24	1	- 2,70 L	\N	5	26	64.38	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3221	3084	FRIG REFORÇADA POLIDA S/ TPA 20	1	- 1,30 L	\N	5	27	22.86	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3222	3085	FRIG REFORÇADA POLIDA S/ TPA 22	1	- 1,80 L	\N	5	27	25.60	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3224	3256	ASSADEIRA RETANGULAR ALTA REFORÇADA 01	1	- 27 X 17,8 X 5 CM	\N	6	28	19.32	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3226	3257	ASSADEIRA RETANGULAR ALTA REFORÇADA 02	1	- 33,2 X 21,2 X 5 CM	\N	6	28	24.95	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3228	3258	ASSADEIRA RETANGULAR ALTA REFORÇADA 03	1	- 34,5 X 23,7 X 5,5 CM	\N	6	28	30.49	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3230	3259	ASSADEIRA RETANGULAR ALTA REFORÇADA 04	1	- 39,4 X 28,2 X 5,8 CM	\N	6	28	42.91	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3232	3260	ASSADEIRA RETANGULAR ALTA REFORÇADA 05	1	- 44,9 X 30,1 X 6,5 CM	\N	6	28	59.05	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3234	3250	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 01	1	- 27 X 17,9 X 3,7 CM	\N	6	28	14.28	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3236	3251	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 02	1	- 31,1 X 21,3 X 3,8 CM	\N	6	28	21.25	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3238	3252	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 03	1	- 34,6 X 23,7 X 4 CM	\N	6	28	26.27	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3240	3253	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 04	1	- 39,3 X 28,2 X 4,2 CM	\N	6	28	36.18	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3242	3254	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 05	1	- 44,6 X 30,1 X 4,5 CM	\N	6	28	46.65	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3244	5127	ASSADEIRA RETANGULAR ALTA FORT FLON 02	1	- 31,1 X 21,1 X 5,2 CM	\N	6	28	51.87	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3246	5128	ASSADEIRA RETANGULAR ALTA FORT FLON 03	1	- 34,5 X 23,7 X 5,5 CM	\N	6	28	62.58	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3248	5233	ASSADEIRA REDONDA FORT FLON 25	1	- 25 X 6,7 CM	\N	6	29	48.54	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3250	3292	ASSADEIRA REDONDA REFORÇADA ACETINADA 15	1	- 15 X 6,5 CM	\N	6	29	11.29	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3252	3006	ASSADEIRA REDONDA REFORÇADA ACETINADA 20	1	- 20 X 6,6 CM	\N	6	29	18.03	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3254	3007	ASSADEIRA REDONDA REFORÇADA ACETINADA 25	1	- 25 X 6,7 CM	\N	6	29	25.20	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3256	3008	ASSADEIRA REDONDA REFORÇADA ACETINADA 30	1	- 30 X 7 CM	\N	6	29	32.21	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3258	3009	ASSADEIRA REDONDA REFORÇADA ACETINADA 35	1	- 35 X 7 CM	\N	6	29	46.75	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3260	3291	ASSADEIRA REDONDA ALTA REFORÇADA ACETINADA 15	1	- 15 X 10 CM	\N	6	29	15.07	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3262	3283	ASSADEIRA REDONDA ALTA REFORÇADA ACETINADA 20	1	- 20 X 10 CM	\N	6	29	21.54	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3264	3284	ASSADEIRA REDONDA ALTA REFORÇADA ACETINADA 25	1	- 25 X 10 CM	\N	6	29	25.36	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3266	3285	ASSADEIRA REDONDA ALTA REFORÇADA ACETINADA 30	1	- 30 X 10 CM	\N	6	29	32.38	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3268	5043	ASSADEIRA DE BOLO C/ TUBO FORT FLON 24	1	- 24 X 8 CM	\N	6	30	41.58	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3270	5044	ASSADEIRA DE BOLO C/ TUBO FORT FLON 26	1	- 26 X 8,4 CM	\N	6	30	46.67	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3223	3086	FRIG REFORÇADA POLIDA S/ TPA 24	1	- 2,20 L	\N	5	27	30.62	t	2025-12-17 21:53:53.302393+00	2026-03-25 13:08:56.342121+00
3272	5045	ASSADEIRA DE PUDIM FORT FLON 20	1	- 20 X 8,1 CM	\N	6	30	28.73	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3274	5046	ASSADEIRA DE PUDIM FORT FLON 22	1	- 22 X 9,3 CM	\N	6	30	36.88	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3276	3116	ASSAD DE BOLO C/ TUBO REFORÇADA ACETINADA 24	1	- 24 X 8 CM	\N	6	30	22.73	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3278	3113	ASSAD DE BOLO C/ TUBO REFORÇADA ACETINADA 26	1	- 26 X 8,4 CM	\N	6	30	25.63	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3290	3305	ASSADEIRA REDONDA ALTA C/ FUNDO REMOVIVEL 15	1	- 15 X 10 CM	\N	6	31	16.70	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3292	3306	ASSADEIRA REDONDA ALTA C/ FUNDO REMOVIVEL 20	1	- 20 X 10 CM	\N	6	31	29.53	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3294	3307	ASSADEIRA REDONDA ALTA C/ FUNDO REMOVIVEL 25	1	- 25 X 10 CM	\N	6	31	37.21	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3296	3308	ASSADEIRA REDONDA BAIXA C/ FUNDO REMOVIVEL 15	1	- 15 X 6,5 CM	\N	6	31	15.48	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3298	3309	ASSADEIRA REDONDA BAIXA C/ FUNDO REMOVIVEL 20	1	- 20 X 6,5 CM	\N	6	31	22.63	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3300	3155	ASSADEIRA REDONDA BAIXA C/ FUNDO REMOVIVEL 25	1	- 25 X 6,5 CM	\N	6	31	33.04	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3302	3295	ASSADEIRA REDONDA BALLERINE CONICA  20	1	- 20 X 7 CM	\N	6	32	14.35	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3304	3296	ASSADEIRA REDONDA BALLERINE CONICA  22	1	- 22 X 8 CM	\N	6	32	18.58	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3306	3297	ASSADEIRA REDONDA BALLERINE CONICA  25	1	- 25 X 9 CM	\N	6	32	23.39	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3308	3286	ASSADEIRA REDONDA BALLERINE RETA 20	1	- 20 X 6,6 CM	\N	6	32	15.34	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3310	3287	ASSADEIRA REDONDA BALLERINE RETA 25	1	- 25 X 6,7 CM	\N	6	32	21.95	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3312	3288	ASSADEIRA REDONDA BALLERINE RETA 30	1	- 30 X 7,0 CM	\N	6	32	28.35	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3314	3002	ASSADEIRA DE PIZZA 20	1	- 20 X 1,6 CM	\N	6	33	9.74	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3316	3003	ASSADEIRA DE PIZZA 25	1	- 25 X 1,7 CM	\N	6	33	14.71	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3318	3004	ASSADEIRA DE PIZZA 30	1	- 30 X 1,8 CM	\N	6	33	22.49	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3320	3005	ASSADEIRA DE PIZZA 35	1	- 35 X 1,8 CM	\N	6	33	32.57	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3322	3240	ASSADEIRA DE PIZZA 35 FURADA	1	- 35 X 1,5 CM	\N	6	33	34.84	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3324	3134	ASSADEIRA DE PAO REFORÇADA 01	1	- 20,4 X 9,4 X 4,6 CM	\N	6	34	13.74	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3326	3135	ASSADEIRA DE PAO REFORÇADA 02	1	- 23,4 X 9,9 X 5,7 CM	\N	6	34	17.47	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3328	3136	ASSADEIRA DE PAO REFORÇADA 03	1	- 27,9 X 10,8 X 6,2 CM	\N	6	34	22.80	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3330	3160	ASSADEIRA DE BOLO CORACAO REFORÇADA 01	1	- 18,5 X 19,1 X 4 CM	\N	6	35	18.74	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3331	3161	ASSADEIRA DE BOLO CORACAO REFORÇADA 02	1	- 24 X 23,3 X 4,5 CM	\N	6	35	27.68	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3282	3137	ASSADEIRA DE PUDIM REFORÇADA ACETINADA 16	1	- 16 X 6,6 CM	\N	6	30	11.55	t	2025-12-17 21:53:53.302393+00	2026-03-25 14:45:48.017122+00
3280	3228	ASSADEIRA DE PUDIM REFORÇADA ACETINADA 14	1	- 14 X 6,2 CM	\N	6	30	8.87	t	2025-12-17 21:53:53.302393+00	2026-03-25 14:46:12.309837+00
3284	3235	ASSADEIRA DE PUDIM REFORÇADA ACETINADA 18	1	- 18 X 7,1 CM	\N	6	30	13.83	t	2025-12-17 21:53:53.302393+00	2026-03-25 14:46:47.45575+00
3286	3115	ASSADEIRA DE PUDIM REFORÇADA ACETINADA 20	1	- 20 X 8,1 CM	\N	6	30	14.97	t	2025-12-17 21:53:53.302393+00	2026-03-25 14:47:35.436825+00
3288	3100	ASSADEIRA DE PUDIM REFORÇADA ACETINADA 22	1	- 22 X 9,0 CM	\N	6	30	17.79	t	2025-12-17 21:53:53.302393+00	2026-03-25 14:50:21.025927+00
3332	3162	ASSADEIRA DE BOLO CORACAO REFORÇADA 03	1	- 31,8 X 31,8 X 5 CM	\N	6	35	49.47	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3333	3246	ASSADEIRA QUADRADA REFORÇADA 01	1	- 21 X 21 X 6 CM	\N	6	36	31.43	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3334	3247	ASSADEIRA QUADRADA REFORÇADA 02	1	- 27 X 27 X 6,5 CM	\N	6	36	43.16	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3335	3248	ASSADEIRA QUADRADA REFORÇADA 03	1	- 34 X 34 X 7 CM	\N	6	36	63.41	t	2025-12-17 21:53:53.302393+00	2025-12-17 21:53:53.302393+00
3116	4782	CANECAO NEW FORT FLON 16	6	6 peças	5213	4	18	41.48	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3118	4783	FERVEDOR NEW FORT FLON C/ TPA VIDRO 12	6	6 peças	5214	4	18	38.98	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3120	4784	FERVEDOR NEW FORT FLON C/ TPA VIDRO 14	6	6 peças	5215	4	18	44.48	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3122	4785	FERVEDOR NEW FORT FLON C/ TPA VIDRO 16	6	6 peças	5216	4	18	56.04	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3137	4682	CANECAO REFORÇADO POLIDO 10	6	6 peças	3049	4	20	15.07	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3139	4673	CANECAO REFORÇADO POLIDO 12	6	6 peças	3061	4	20	16.94	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3141	4674	CANECAO REFORÇADO POLIDO 14	6	6 peças	3062	4	20	21.18	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3143	4675	CANECAO REFORÇADO POLIDO 16	6	6 peças	3063	4	20	25.78	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3145	4683	CANECAO REFORÇADO POLIDO 18	6	6 peças	3044	4	20	47.28	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3147	4676	FERVEDOR REFORÇADO POLIDO 12	6	6 peças	3081	4	20	22.97	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3149	4677	FERVEDOR REFORÇADO POLIDO 14	6	6 peças	3082	4	20	28.04	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3151	4678	FERVEDOR REFORÇADO POLIDO 16	6	6 peças	3083	4	20	34.94	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3153	4679	CANECAO REFORÇADO POLIDO C/ CABO MADEIRA 12	6	6 peças	3218	4	20	22.85	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3155	4680	CANECAO REFORÇADO POLIDO C/ CABO MADEIRA 14	6	6 peças	3219	4	20	27.00	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3157	4681	CANECAO REFORÇADO POLIDO C/ CABO MADEIRA 16	6	6 peças	3220	4	20	31.87	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3159	4684	CANECAO REFORÇADO POLIDO C/ CABO MADEIRA 18	6	6 peças	3064	4	20	37.93	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3352	3087	JARRA CONICA REFORÇADA POLIDA 01	1	- 1,40 L	\N	9	37	17.24	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3354	3088	JARRA BOJUDA REFORÇADA POLIDA 00	1	- 0,70 L	\N	9	38	11.82	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3356	3089	JARRA BOJUDA REFORÇADA POLIDA 01	1	- 1,50 L	\N	9	38	19.99	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3358	3090	JARRA BOJUDA REFORÇADA POLIDA 02	1	- 2,40 L	\N	9	38	21.99	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3360	3234	MARMITA OPERARIA REFORÇADA FOSCA 10	1	- 0,45 L	\N	10	39	9.89	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3362	3114	MARMITA OPERARIA REFORÇADA FOSCA 12	1	- 0,65 L	\N	10	39	14.30	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3364	3092	MARMITA OPERARIA REFORÇADA FOSCA 14	1	- 1,00 L	\N	10	39	16.77	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3366	3093	MARMITA OPERARIA REFORÇADA FOSCA 16	1	- 1,30 L	\N	10	39	20.49	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3368	3201	MARMITA OPERARIA REFORÇADA FOSCA C/ TRAVA 16	1	- 1,30 L	\N	10	39	23.11	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3369	3094	MARMITA OPERARIA REFORÇADA FOSCA 18	1	- 1,80 L	\N	10	39	24.53	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3371	3096	JG DE MARMITA REFORÇADO POLIDO 16X5	1	16X5	\N	10	40	116.81	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3372	3097	JG DE MARMITA REFORÇADO POLIDO 16X6	1	16X6	\N	10	40	136.45	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3373	3098	JG DE MARMITA REFORÇADO POLIDO 18X5	1	18X5	\N	10	40	135.81	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3374	3099	JG DE MARMITA REFORÇADO POLIDO 18X6	1	18X6	\N	10	40	161.01	t	2025-12-17 21:59:12.674094+00	2025-12-17 21:59:12.674094+00
3161	4059	JOGO CANECOES REFORÇADO CRAQUEADO 12 A 16	1	12-14-16	\N	4	22	70.00	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3162	4098	JOGO CANECOES REFORÇADO VERMELHO 12 A 16	1	12-14-16	\N	4	22	70.00	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3163	4139	JOGO CANECOES REFORÇADO PRETO 12 A 16	1	12-14-16	\N	4	22	70.00	t	2025-12-16 23:02:44.18885+00	2026-03-16 22:49:10.920493+00
3181	4792	FRIG NEW FORT FLON 22 - TPA VIDRO	6	6 peças	5223	5	23	54.87	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3183	4793	FRIG NEW FORT FLON 24 - TPA VIDRO	6	6 peças	5224	5	23	61.68	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3185	4786	FRIG NEW FORT FLON S/ TPA 18	6	6 peças	5217	5	23	27.44	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3187	4787	FRIG NEW FORT FLON S/ TPA 20	6	6 peças	5218	5	23	32.62	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3189	4788	FRIG NEW FORT FLON S/ TPA 22	6	6 peças	5219	5	23	38.15	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3191	4789	FRIG NEW FORT FLON S/ TPA 24	6	6 peças	5220	5	23	42.78	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3193	4801	BISTEQUEIRA CANELADA QUADRADA FORT FLON	6	6 peças	5079	5	23	93.47	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3195	4804	CREPEIRA / PANQUEQUEIRA FORT FLON 20	6	6 peças	5103	5	23	38.84	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3197	4800	CREPEIRA / PANQUEQUEIRA FORT FLON 22	6	6 peças	5076	5	23	45.66	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3200	4802	OMELETEIRA FORT FLON 20	6	6 peças	5101	5	23	69.74	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3202	4803	OMELETEIRA FORT FLON 22	6	6 peças	5102	5	23	78.15	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3225	4721	ASSADEIRA RETANGULAR ALTA REFORÇADA 01	6	6 peças	3256	6	28	18.16	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3227	4722	ASSADEIRA RETANGULAR ALTA REFORÇADA 02	6	6 peças	3257	6	28	23.45	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3229	4723	ASSADEIRA RETANGULAR ALTA REFORÇADA 03	6	6 peças	3258	6	28	28.66	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3392	3014	BACIA REFORÇADA FOSCA 15	1	- 15 X 4,5 CM	\N	12	\N	4.70	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3231	4724	ASSADEIRA RETANGULAR ALTA REFORÇADA 04	6	6 peças	3259	6	28	40.34	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3393	3015	BACIA REFORÇADA FOSCA 20	1	- 20 X 5,5 CM	\N	12	\N	7.42	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3394	3016	BACIA REFORÇADA FOSCA 25	1	- 25 X 6,5 CM	\N	12	\N	12.18	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3395	3017	BACIA REFORÇADA FOSCA 30	1	- 30 X 7,5 CM	\N	12	\N	19.70	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3396	3018	BACIA REFORÇADA FOSCA 35	1	- 35 X 9 CM	\N	12	\N	25.62	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3397	3019	BACIA REFORÇADA FOSCA 40	1	- 40 X 9,5 CM	\N	12	\N	32.30	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3398	3020	BACIA REFORÇADA FOSCA 45	1	- 45 X 10 CM	\N	12	\N	41.48	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3399	3021	BACIA REFORÇADA FOSCA 50	1	- 50 X 12,5 CM	\N	12	\N	49.98	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3400	3022	BACIA REFORÇADA FOSCA 55	1	- 55 X 13 CM	\N	12	\N	62.99	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3401	3023	BACIA REFORÇADA FOSCA 60	1	- 60 X 14 CM	\N	12	\N	82.24	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3402	3167	BACIA REFORÇADA FOSCA 70	1	- 70 X 15 CM	\N	12	\N	133.01	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3403	3024	BALDE REFORÇADO ACETINADO 12	1	- 12,30 L	\N	12	\N	70.57	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3404	3130	BALDE DE GELO REFORÇADO ESCOVADO 22	1	- 5,80 L	\N	12	\N	47.43	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3405	4024	BALDE DE GELO REFORÇADO ESCOVADO 22 C/ CAIXA	1	- 5,80 L	\N	12	\N	55.10	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3407	3026	BANDEJA REDONDA REFORÇADA POLIDA 40	1	- 40 X 2 CM	\N	12	\N	46.84	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3408	3091	LAVARROZ REFORÇADO FOSCO 2O	1	- 24 X 8,5 CM	\N	13	\N	21.53	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3409	3102	ESCORREDOR DE MACARRAO REFORÇADO FOSCO 22	1	- 22 X 13 CM	\N	13	\N	31.99	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3410	3103	ESCORREDOR DE MACARRAO REFORÇADO FOSCO 24	1	- 24 X 14,5 CM	\N	13	\N	34.60	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3411	3104	PRATO REFORÇADO ACETINADO 22	1	- 22 X 3 CM	\N	13	\N	10.41	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3412	3025	BULE REFORÇADO POLIDO 02	1	- 1,20 L	\N	14	\N	35.50	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3413	3065	CAFETEIRA REFORÇADA POLIDA C/ COADOR 02	1	- 2,00 L	\N	14	\N	45.58	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3414	3095	CHALEIRA REFORÇADA POLIDA 18	1	- 2,95 L	\N	14	\N	58.51	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3415	3077	DEPOSITO  DE LEITE REFORÇADO FOSCO 02	1	- 2,60 L	\N	15	\N	28.98	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3416	3078	DEPOSITO  DE LEITE REFORÇADO FOSCO 03	1	- 3,70 L	\N	15	\N	34.40	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3417	3079	DEPOSITO  DE LEITE REFORÇADO FOSCO 05	1	- 6,50 L	\N	15	\N	55.16	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3418	3132	DEPOSITO  DE LEITE REFORÇADO FOSCO 01	1	- 1,20 L	\N	15	\N	17.46	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3419	3310	CUSCUZEIRO INDIVIDUAL TETINHA POLIDO 10	1	- 0,35 L	\N	16	\N	27.50	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3233	4725	ASSADEIRA RETANGULAR ALTA REFORÇADA 05	6	6 peças	3260	6	28	55.51	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3421	3311	CUSCUZEIRO INDIVIDUAL COZI VAPOR 10	1	- 0,45 L	\N	16	\N	27.50	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3235	4716	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 01	6	6 peças	3250	6	28	13.42	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3423	3289	CUSCUZEIRO REFORÇADO POLIDO 14	1	- 1,40 L	\N	16	\N	32.81	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3237	4717	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 02	6	6 peças	3251	6	28	19.98	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3425	3290	CUSCUZEIRO REFORÇADO POLIDO 16	1	- 2,00 L	\N	16	\N	39.31	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3239	4718	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 03	6	6 peças	3252	6	28	24.70	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3427	3051	CUSCUZEIRO REFORÇADO POLIDO 18	1	- 3,10 L	\N	16	\N	47.93	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3241	4719	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 04	6	6 peças	3253	6	28	34.01	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3429	3117	CONJUNTO BANHO MARIA REFORÇADO POLIDO 20	1	- 3 X 1	\N	17	\N	60.41	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3243	4720	ASSADDEIRA RETANGULAR BAIXA REFORÇADA 05	6	6 peças	3254	6	28	43.85	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3245	4767	ASSADEIRA RETANGULAR ALTA FORT FLON 02	6	6 peças	5127	6	28	48.76	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3247	4768	ASSADEIRA RETANGULAR ALTA FORT FLON 03	6	6 peças	5128	6	28	58.82	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3433	3142	CONJUNTO MULTIUSO REFORÇADO POLIDO 20	1	- 6 X 1	\N	17	\N	72.34	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3249	4766	ASSADEIRA REDONDA FORT FLON 25	6	6 peças	5233	6	29	45.63	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3251	4715	ASSADEIRA REDONDA REFORÇADA ACETINADA 15	6	6 peças	3292	6	29	10.61	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3253	4700	ASSADEIRA REDONDA REFORÇADA ACETINADA 20	6	6 peças	3006	6	29	16.95	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3255	4701	ASSADEIRA REDONDA REFORÇADA ACETINADA 25	6	6 peças	3007	6	29	23.68	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3257	4702	ASSADEIRA REDONDA REFORÇADA ACETINADA 30	6	6 peças	3008	6	29	30.27	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3441	3139	PIPOQUEIRA REFORÇADA POLIDA 20	1	- 4,20 L	\N	18	\N	84.93	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3259	4703	ASSADEIRA REDONDA REFORÇADA ACETINADA 35	6	6 peças	3009	6	29	43.94	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3261	4704	ASSADEIRA REDONDA ALTA REFORÇADA ACETINADA 15	6	6 peças	3291	6	29	14.16	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3263	4705	ASSADEIRA REDONDA ALTA REFORÇADA ACETINADA 20	6	6 peças	3283	6	29	20.25	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3445	7154	PIPOQUEIRA REFORÇADA POLIDA 20	1	- 3,20 L	\N	18	\N	52.53	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3265	4706	ASSADEIRA REDONDA ALTA REFORÇADA ACETINADA 25	6	6 peças	3284	6	29	23.84	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3447	3101	MORINGA REFORÇADA POLIDA 02	1	- 1,80 L	\N	19	\N	27.72	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3267	4707	ASSADEIRA REDONDA ALTA REFORÇADA ACETINADA 30	6	6 peças	3285	6	29	30.44	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3449	3157	GUARDA OLEO REFORÇADO POLIDO C/ PENEIRA 11	1	- 1,00 L - 13 CM ALTURA	\N	20	\N	22.55	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3269	4762	ASSADEIRA DE BOLO C/ TUBO FORT FLON 24	6	6 peças	5043	6	30	39.08	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3451	3245	ESPAGUETEIRA REFORÇADA POLIDA 20	1	- 4,40 L	\N	21	\N	79.73	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3452	5017	CONCHA NYLON	1	- 30 X 9 CM	\N	22	41	6.30	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3453	5018	ESPATULA NYLON	1	- 31 X 9 CM	\N	22	41	6.30	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3454	5019	ESPUMADEIRA NYLON	1	- 28 X 11	\N	22	41	6.30	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3455	3050	CONCHA BABY REFORÇADA FOSCA 08	1	- 25 X 8 CM	\N	22	41	14.94	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3437	3158	VAPOLAR REFORÇADO POLIDO 20 S/ CAIXA	1	- 2 X 1	\N	17	\N	69.88	t	2025-12-17 22:05:25.012965+00	2026-03-25 14:52:33.64267+00
3438	4046	VAPOLAR REFORÇADO POLIDO 20 C/ CAIXA	1	- 2 x 1	\N	17	\N	72.53	t	2025-12-17 22:05:25.012965+00	2026-03-25 14:53:38.394667+00
3456	3066	CONCHA REFORÇADA POLIDA 09	1	- 28 X 9 CM	\N	22	41	17.73	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3457	3151	CONCHA SUPER FOSCA 09	1	- 26 X 9 CM	\N	22	41	15.38	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3458	3080	ESPUMADEIRA REFORÇADA POLIDA 09	1	- 28 X 9 CM	\N	22	41	13.71	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3459	3133	ESPUMADEIRA BABY REFORÇADA FOSCA 08	1	- 24 X 8 CM	\N	22	41	12.41	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3460	3152	ESPUMADEIRA SUPER FOSCA 09	1	- 28 X 9 CM	\N	22	41	13.39	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3461	6016	CONCHA SUPER FOSCA 12	1	- 42 X 12 CM	\N	22	42	22.82	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3462	6018	ESPUMADEIRA SUPER FOSCA 13	1	- 42 X 13 CM	\N	22	42	21.46	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3463	301	TAMPA BOJ POL 16	1	16	\N	23	43	10.97	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3464	302	TAMPA BOJ POL 18	1	18	\N	23	43	12.40	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3465	303	TAMPA BOJ POL 20	1	20	\N	23	43	13.97	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3466	314	TAMPA BOJ POL 22	1	22	\N	23	43	18.20	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3467	324	TAMPA BOJ POL 24	1	24	\N	23	43	24.37	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3468	522	TAMPA DE VIDRO 12	1	12	\N	23	44	11.02	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3469	521	TAMPA DE VIDRO 14	1	14	\N	23	44	11.02	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3470	511	TAMPA DE VIDRO 16	1	16	\N	23	44	11.51	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3471	512	TAMPA DE VIDRO 18	1	18	\N	23	44	12.44	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3271	4763	ASSADEIRA DE BOLO C/ TUBO FORT FLON 26	6	6 peças	5044	6	30	43.87	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3473	514	TAMPA DE VIDRO 22	1	22	\N	23	44	14.62	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3474	515	TAMPA DE VIDRO 24	1	24	\N	23	44	16.18	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3475	520	TAMPA DE VIDRO 26	1	26	\N	23	44	17.87	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3476	517	TAMPA DE VIDRO 28	1	28	\N	23	44	19.66	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3477	518	TAMPA DE VIDRO 30	1	30	\N	23	44	21.74	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3478	519	TAMPA DE VIDRO 32	1	32	\N	23	44	23.83	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3479	3105	TAMPA COMUM FOSCA 10	1	10	\N	23	45	3.05	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3480	3106	TAMPA COMUM FOSCA 12	1	12	\N	23	45	3.92	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3481	3107	TAMPA COMUM FOSCA 14	1	14	\N	23	45	6.33	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3482	3108	TAMPA COMUM FOSCA 16	1	16	\N	23	45	7.03	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3483	3109	TAMPA COMUM FOSCA 18	1	18	\N	23	45	8.09	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3484	3110	TAMPA COMUM FOSCA 20	1	20	\N	23	45	9.26	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3485	3111	TAMPA COMUM FOSCA 22	1	22	\N	23	45	11.87	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3486	3112	TAMPA COMUM FOSCA 24	1	24	\N	23	45	13.74	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3487	3149	TAMPA COMUM FOSCA 26	1	26	\N	23	45	18.14	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3488	3150	TAMPA COMUM FOSCA 28	1	28	\N	23	45	19.25	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3489	3123	TAMPA COMUM FOSCA 30	1	30	\N	23	45	26.57	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3490	3124	TAMPA COMUM FOSCA 36	1	36	\N	23	45	34.66	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3491	3125	TAMPA COMUM FOSCA 40	1	40	\N	23	45	44.66	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3492	3193	TAMPA COMUM FOSCA 45	1	45	\N	23	45	58.40	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3273	4764	ASSADEIRA DE PUDIM FORT FLON 20	6	6 peças	5045	6	30	27.01	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3275	4765	ASSADEIRA DE PUDIM FORT FLON 22	6	6 peças	5046	6	30	34.66	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3277	4713	ASSAD DE BOLO C/ TUBO REFORÇADA ACETINADA 24	6	6 peças	3116	6	30	21.36	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3279	4714	ASSAD DE BOLO C/ TUBO REFORÇADA ACETINADA 26	6	6 peças	3113	6	30	24.09	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3281	4708	ASSADDEIRA DE PUDIM REF ORÇADA ACETINADA 14	6	6 peças	3228	6	30	8.34	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3283	4709	ASSADDEIRA DE PUDIM REF ORÇADA ACETINADA 16	6	6 peças	3137	6	30	10.85	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3285	4710	ASSADDEIRA DE PUDIM REF ORÇADA ACETINADA 18	6	6 peças	3235	6	30	13.00	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3287	4711	ASSADDEIRA DE PUDIM REF ORÇADA ACETINADA 20	6	6 peças	3115	6	30	14.07	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3289	4712	ASSADDEIRA DE PUDIM REF ORÇADA ACETINADA 22	6	6 peças	3100	6	30	16.72	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3291	4735	ASSADEIRA REDONDA ALTA C/ FUNDO REMOVIVEL 15	6	6 peças	3305	6	31	15.70	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3293	4736	ASSADEIRA REDONDA ALTA C/ FUNDO REMOVIVEL 20	6	6 peças	3306	6	31	27.76	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3295	4737	ASSADEIRA REDONDA ALTA C/ FUNDO REMOVIVEL 25	6	6 peças	3307	6	31	34.97	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3297	4732	ASSADEIRA REDONDA BAIXA C/ FUNDO REMOVIVEL 15	6	6 peças	3308	6	31	14.55	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3299	4733	ASSADEIRA REDONDA BAIXA C/ FUNDO REMOVIVEL 20	6	6 peças	3309	6	31	21.27	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3301	4734	ASSADEIRA REDONDA BAIXA C/ FUNDO REMOVIVEL 25	6	6 peças	3155	6	31	31.06	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3303	4729	ASSADEIRA REDONDA BALLERINE CONICA  20	6	6 peças	3295	6	32	13.49	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3509	7132	CONJUNTO PRATIK FLON 4 PCS C/ TPA VIDRO	1	TPA VIDRO	\N	24	46	152.47	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3305	4730	ASSADEIRA REDONDA BALLERINE CONICA  22	6	6 peças	3296	6	32	17.46	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3307	4731	ASSADEIRA REDONDA BALLERINE CONICA  25	6	6 peças	3297	6	32	21.99	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3309	4726	ASSADEIRA REDONDA BALLERINE RETA 20	6	6 peças	3286	6	32	14.42	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3311	4727	ASSADEIRA REDONDA BALLERINE RETA 25	6	6 peças	3287	6	32	20.63	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3313	4728	ASSADEIRA REDONDA BALLERINE RETA 30	6	6 peças	3288	6	32	26.65	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3315	4695	ASSADEIRA DE PIZZA 20	6	6 peças	3002	6	33	9.16	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3516	4412	FEIRINHA POLIDA 120 PCS	1	120 PÇS	\N	25	\N	2810.19	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3517	4413	FEIRINHA POLIDA 60 PCS	1	60 PÇS	\N	25	\N	1404.95	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3518	4414	FEIRINHA ASSADEIRAS 72 PCS	1	72 PÇS	\N	25	\N	1712.46	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3519	4415	FEIRINHA PANELA - CANECAO POLIDO - 48 PCS	1	48 PÇS	\N	25	\N	1304.32	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3520	4417	FEIRINHA ASSADEIRAS 36 PCS	1	36 PÇS	\N	25	\N	852.27	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3521	4418	FEIRINHA PANELA - CANECAO POLIDO - 24 PCS	1	24 PÇS	\N	25	\N	623.85	t	2025-12-17 22:05:25.012965+00	2025-12-17 22:05:25.012965+00
3317	4696	ASSADEIRA DE PIZZA 25	6	6 peças	3003	6	33	13.82	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3319	4697	ASSADEIRA DE PIZZA 30	6	6 peças	3004	6	33	21.14	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3321	4698	ASSADEIRA DE PIZZA 35	6	6 peças	3005	6	33	30.61	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3323	4699	ASSADEIRA DE PIZZA 35 FURADA	6	6 peças	3240	6	33	32.75	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3325	4738	ASSADEIRA DE PAO REFORÇADA 01	6	6 peças	3134	6	34	12.91	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3327	4739	ASSADEIRA DE PAO REFORÇADA 02	6	6 peças	3135	6	34	16.42	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3329	4740	ASSADEIRA DE PAO REFORÇADA 03	6	6 peças	3136	6	34	21.43	t	2025-12-17 21:53:53.302393+00	2026-03-16 22:55:26.659158+00
3336	5178	CACAROLA WOK FORT FLON 26 C/ ASAS - SEM TPA	1	- 3,60 L	\N	7	\N	71.80	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3431	4001	CONJUNTO BANHO MARIA REFORÇADO POLIDO 20  C/ CAIXA	1	- 3 X 1	\N	17	\N	69.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3337	5173	CACAROLA WOK FORT FLON 26 C/ ASAS - TPA VIDRO	1	- 3,60 L	\N	7	\N	95.73	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3338	5180	CACAROLA WOK FORT FLON 28 C/ ASAS - SEM TPA	1	- 4,60 L	\N	7	\N	82.19	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3435	4085	CONJUNTO MULTIUSO REFORÇADO POLIDO 20 C/ CAIXA	1	- 6 X 1	\N	17	\N	71.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3339	5175	CACAROLA WOK FORT FLON 28 C/ ASAS - TPA VIDRO	1	- 4,60 L	\N	7	\N	107.67	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3340	5169	PAELLEIRA FORT FLON C/ ASAS 30	1	- 1,50 L	\N	7	\N	134.07	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3341	5170	PAELLEIRA FORT FLON C/ ASAS 32	1	- 2,00 L	\N	7	\N	149.74	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3342	5177	PANELA WOK FORT FLON 26 C/ CABO  - SEM TPA	1	- 3,60 L	\N	7	\N	69.20	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3443	4017	PIPOQUEIRA REFORÇADA POLIDA 20 C/ CAIXA	1	- 4,20 L	\N	18	\N	70.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3343	5174	PANELA WOK FORT FLON 26 C/ CABO  - TPA VIDRO	1	- 3,60 L	\N	7	\N	92.39	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3344	5179	PANELA WOK FORT FLON 28 C/ CABO - SEM TPA	1	- 4,60 L	\N	7	\N	79.01	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3345	5176	PANELA WOK FORT FLON 28 C/ CABO - TPA VIDRO	1	- 4,60 L	\N	7	\N	104.37	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3346	3042	COPO RETO REFORÇADO POLIDO C/ ASA 07	1	- 0,33 L	\N	8	\N	10.41	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3472	513	TAMPA DE VIDRO 20	1	20	\N	23	44	13.68	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3493	4008	CONJUNTO PANELEIRO PRATIK LAR 5 PCS	1	5 PÇS	\N	24	46	135.90	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3347	3043	COPO CONICO REFORÇADO POLIDO C/ ASA 09	1	- 0,53 L	\N	8	\N	13.21	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3495	4009	CONJUNTO PANELEIRO PRATIK FLON 5 PCS	1	5 PÇS	\N	24	46	172.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3348	3053	COPO RETO REFORÇADO FOSCO C/ ASA 07	1	- 0,27 L	\N	8	\N	6.55	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3497	4018	CONJUNTO PANELEIRO CLASSIC 6 PCS C/ PP	1	6 PÇS	\N	24	46	229.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3349	3054	COPO RETO REFORÇADO FOSCO C/ ASA 08	1	- 0,40 L	\N	8	\N	7.35	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3499	4034	CONJUNTO PANELEIRO FORT FLON 6 PCS C/ PP	1	6 PÇS	\N	24	46	204.90	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3350	3055	COPO RETO REFORÇADO FOSCO C/ ASA 09	1	- 0,52 L	\N	8	\N	7.69	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3351	3067	COPO CONICO REFORÇADO POLIDO 08	1	- 0,36 L	\N	8	\N	6.49	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3353	4741	JARRA CONICA REFORÇADA POLIDA 01	6	6 peças	3087	9	37	16.21	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3501	4048	CONJUNTO PANELEIRO PLATINUM 7 PCS C/ PP	1	7 PÇS	\N	24	46	186.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3503	4049	CONJUNTO PANELEIRO PLATINUM 9 PCS C/ PP	1	9 PÇS	\N	24	46	226.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3355	4742	JARRA BOJUDA REFORÇADA POLIDA 00	6	6 peças	3088	9	38	11.11	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3505	4050	CONJUNTO PANELEIRO FORT FLON 7 PCS C/ PP	1	7 PÇS	\N	24	46	248.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3357	4743	JARRA BOJUDA REFORÇADA POLIDA 01	6	6 peças	3089	9	38	18.79	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3507	4051	CONJUNTO PANELEIRO FORT FLON 9 PCS C/ PP	1	9 PÇS	\N	24	46	329.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3359	4744	JARRA BOJUDA REFORÇADA POLIDA 02	6	6 peças	3090	9	38	20.67	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3510	4056	JOGG CACAROLAS CONICA PLUS CRAQUEADA 16 A 24 - TPA ALUMINIO	1	TPA ALUMINIO	\N	24	47	220.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3511	4086	JOGO CACAROLAS CONICA PLUS VERMELHA 16 A 24 - TPA ALUMINIO	1	TPA ALUMINIO	\N	24	47	220.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3512	4127	JOGO CACAROLAS CONICA PLUS VERMELHA 16 A 24 - TPA VIDRO	1	TPA VIDRO	\N	24	47	275.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3513	4128	JOGO CACAROLAS CONICA PLUS PRETA 16 A 24 - TPA ALUMINIO	1	TPA ALUMINIO	\N	24	47	220.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3514	4129	JOGO CACAROLAS CONICA PLUS PRETA 16 A 24 - TPA VIDRO	1	TPA VIDRO	\N	24	47	275.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3515	4131	JOGO CACAROLAS CONICA PLUS CRAQUEADA 16 A 24 - TPA VIDRO	1	TPA VIDRO	\N	24	47	275.00	t	2025-12-17 22:05:25.012965+00	2026-03-04 20:04:29.134468+00
3361	4745	MARMITA OPERARIA REFORÇADA FOSCA 10	6	6 peças	3234	10	39	9.30	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3363	4746	MARMITA OPERARIA REFORÇADA FOSCA 12	6	6 peças	3114	10	39	13.44	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3365	4747	MARMITA OPERARIA REFORÇADA FOSCA 14	6	6 peças	3092	10	39	15.76	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3367	4748	MARMITA OPERARIA REFORÇADA FOSCA 16	6	6 peças	3093	10	39	19.26	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3420	4753	CUSCUZEIRO INDIVIDUAL TETINHA POLIDO 10	6	6 peças	3310	16	\N	25.85	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3422	4754	CUSCUZEIRO INDIVIDUAL COZI VAPOR 10	6	6 peças	3311	16	\N	25.85	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3370	4749	MARMITA OPERARIA REFORÇADA FOSCA 18	6	6 peças	3094	10	39	23.06	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3375	3212	DEPOSITO DE CEREAL REFORÇADO POLIDO 12	1	- 1,30 L	\N	11	\N	18.80	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3376	3213	DEPOSITO DE CEREAL REFORÇADO POLIDO 14	1	- 2,00 L	\N	11	\N	25.68	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3377	3214	DEPOSITO DE CEREAL REFORÇADO POLIDO 16	1	- 2,90 L	\N	11	\N	27.96	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3378	3215	DEPOSITO DE CEREAL REFORÇADO POLIDO 18	1	- 4,00 L	\N	11	\N	35.27	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3379	3216	DEPOSITO DE CEREAL REFORÇADO POLIDO 20	1	- 5,50 L	\N	11	\N	44.78	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3380	3217	DEPOSITO DE CEREAL REFORÇADO POLIDO 22	1	- 7,60 L	\N	11	\N	58.43	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3381	3074	DEPOSITO DE CEREAL REFORÇADO ACETINADO 24	1	- 10,20 L	\N	11	\N	66.91	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3382	3075	DEPOSITO DE CEREAL REFORÇADO ACETINADO 26	1	- 13,20 L	\N	11	\N	80.62	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3383	3076	DEPOSITO DE CEREAL REFORÇADO ACETINADO 26 C/ ASAS	1	- 13,20 L	\N	11	\N	105.18	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3384	3187	DEPOSITO DE CEREAL REFORÇADO ACETINADO 28	1	- 16,70 L	\N	11	\N	101.21	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3385	3188	DEPOSITO DE CEREAL REFORÇADO ACETINADO 30	1	- 21,20 L	\N	11	\N	119.61	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3386	3189	DEPOSITO DE CEREAL REFORÇADO ACETINADO 28 C/ ASAS	1	- 16,70 L	\N	11	\N	124.04	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3387	3190	DEPOSITO DE CEREAL REFORÇADO ACETINADO 30 C/ ASAS	1	- 21,20 L	\N	11	\N	142.48	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3388	4030	JOGO DEPOSITO CEREAIS REFORÇADO POLIDO 12 A 20	1	- 12 A 20	\N	11	\N	116.90	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3389	4547	JOGO DEPOSITO CEREAIS REFORÇADO POLIDO 12 A 20	3	3 peças	4030	11	\N	115.01	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3390	4031	JOGO DEPOSITO CEREAIS REFORÇADO POLIDO 14 A 22	1	- 14 A 22	\N	11	\N	151.90	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3391	4548	JOGO DEPOSITO CEREAIS REFORÇADO POLIDO 14 A 22	3	3 peças	4031	11	\N	141.95	t	2025-12-17 21:59:12.674094+00	2026-03-16 23:01:57.822704+00
3424	4750	CUSCUZEIRO REFORÇADO POLIDO 14	6	6 peças	3289	16	\N	30.84	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
2902	9089	PANELA DE PRESSAO FECH EXTERNO POLIDA 3,00 LITROS	1	- 3,00 L	\N	1	1	129.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2903	4805	PANELA DE PRESSAO FECH EXTERNO POLIDA 3,00 LITROS	6	6 peças	9089	1	1	117.78	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2904	4806	PANELA DE PRESSAO FECH EXTERNO POLIDA 3,00 LITROS	12	12 peças	9089	1	1	116.57	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2905	9090	PANELA DE PRESSAO FECH EXTERNO POLIDA 4,50 LITROS	1	- 4,50 L	\N	1	1	136.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2906	4807	PANELA DE PRESSAO FECH EXTERNO POLIDA 4,50 LITROS	6	6 peças	9090	1	1	130.58	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2907	4808	PANELA DE PRESSAO FECH EXTERNO POLIDA 4,50 LITROS	12	12 peças	9090	1	1	129.24	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2908	9091	PANELA DE PRESSAO FECH EXTERNO ANTIADERENTE FORT FLON 3,00 LITROS	1	- 3,00 L	\N	1	1	143.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2909	4809	PANELA DE PRESSAO FECH EXTERNO ANTIADERENTE FORT FLON 3,00 LITROS	6	6 peças	9091	1	1	133.70	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2910	4810	PANELA DE PRESSAO FECH EXTERNO ANTIADERENTE FORT FLON 3,00 LITROS	12	12 peças	9091	1	1	132.33	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2911	9092	PANELA DE PRESSAO FECH EXTERNO ANTIADERENTE FORT FLON 4,50 LITROS	1	- 4,50 L	\N	1	1	159.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2912	4811	PANELA DE PRESSAO FECH EXTERNO ANTIADERENTE FORT FLON 4,50 LITROS	6	6 peças	9092	1	1	151.66	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2913	4812	PANELA DE PRESSAO FECH EXTERNO ANTIADERENTE FORT FLON 4,50 LITROS	12	12 peças	9092	1	1	150.09	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2914	9079	PANELA DE PRESSAO POLIDA 2,50 LITROS	1	- 2,50 L	\N	1	2	49.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2915	4601	PANELA DE PRESSAO POLIDA 2,50 LITROS	6	6 peças	9079	1	2	45.79	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2916	4602	PANELA DE PRESSAO POLIDA 2,50 LITROS	12	12 peças	9079	1	2	45.30	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2917	4633	PANELA DE PRESSAO POLIDA 2,50 LITROS	24	24 peças	9079	1	2	45.08	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2918	9080	PANELA DE PRESSAO COLOR 2,50 LITROS - VERMELHA	1	- 2,50 L	\N	1	2	53.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2919	4607	PANELA DE PRESSAO COLOR 2,50 LITROS - VERMELHA	6	6 peças	9080	1	2	51.16	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2920	4608	PANELA DE PRESSAO COLOR 2,50 LITROS - VERMELHA	12	12 peças	9080	1	2	50.61	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2921	4645	PANELA DE PRESSAO COLOR 2,50 LITROS - VERMELHA	24	24 peças	9080	1	2	50.39	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2922	9081	PANELA DE PRESSAO COLOR 2,50 LITROS - PRETA	1	- 2,50 L	\N	1	2	53.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2923	4605	PANELA DE PRESSAO COLOR 2,50 LITROS - PRETA	6	6 peças	9081	1	2	51.16	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2924	4606	PANELA DE PRESSAO COLOR 2,50 LITROS - PRETA	12	12 peças	9081	1	2	50.61	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2925	4641	PANELA DE PRESSAO COLOR 2,50 LITROS - PRETA	24	24 peças	9081	1	2	50.39	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2926	9082	PANELA DE PRESSAO COLOR 2,50 LITROS- CRAQUEADA	1	- 2,50 L	\N	1	2	53.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2927	4603	PANELA DE PRESSAO COLOR 2,50 LITROS- CRAQUEADA	6	6 peças	9082	1	2	51.16	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2928	4604	PANELA DE PRESSAO COLOR 2,50 LITROS- CRAQUEADA	12	12 peças	9082	1	2	50.61	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2929	4637	PANELA DE PRESSAO COLOR 2,50 LITROS- CRAQUEADA	24	24 peças	9082	1	2	50.39	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2930	9036	PANELA DE PRESSAO POLIDA 3,00 LITROS	1	- 3,00 L	\N	1	3	55.30	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2931	4557	PANELA DE PRESSAO POLIDA 3,00 LITROS	6	6 peças	9036	1	3	53.14	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2932	4558	PANELA DE PRESSAO POLIDA 3,00 LITROS	12	12 peças	9036	1	3	52.63	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2933	4559	PANELA DE PRESSAO POLIDA 3,00 LITROS	24	24 peças	9036	1	3	51.99	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2934	9037	PANELA DE PRESSAO ANTIADERENTE FORT FLON 3,00 LITROS	1	- 3,00 L	\N	1	3	88.50	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2935	4567	PANELA DE PRESSAO ANTIADERENTE FORT FLON 3,00 LITROS	6	6 peças	9037	1	3	84.56	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2936	4568	PANELA DE PRESSAO ANTIADERENTE FORT FLON 3,00 LITROS	12	12 peças	9037	1	3	84.21	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2937	9039	PANELA DE PRESSAO COLOR 3,00 LITROS - CRAQUEADA	1	- 3,00 L	\N	1	3	61.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2938	4609	PANELA DE PRESSAO COLOR 3,00 LITROS - CRAQUEADA	6	6 peças	9039	1	3	59.04	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2939	4610	PANELA DE PRESSAO COLOR 3,00 LITROS - CRAQUEADA	12	12 peças	9039	1	3	58.50	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2940	4649	PANELA DE PRESSAO COLOR 3,00 LITROS - CRAQUEADA	24	24 peças	9039	1	3	58.02	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2941	9070	PANELA DE PRESSAO COLOR 3,00 LITROS - PRETA	1	- 3,00 L	\N	1	3	61.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2942	4611	PANELA DE PRESSAO COLOR 3,00 LITROS - PRETA	6	6 peças	9070	1	3	59.04	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2943	4612	PANELA DE PRESSAO COLOR 3,00 LITROS - PRETA	12	12 peças	9070	1	3	58.50	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2944	4652	PANELA DE PRESSAO COLOR 3,00 LITROS - PRETA	24	24 peças	9070	1	3	58.02	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2945	9045	PANELA DE PRESSAO COLOR 3,00 LITROS - VERMELHA	1	- 3,00 L	\N	1	3	61.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2946	4613	PANELA DE PRESSAO COLOR 3,00 LITROS - VERMELHA	6	6 peças	9045	1	3	59.04	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2947	4614	PANELA DE PRESSAO COLOR 3,00 LITROS - VERMELHA	12	12 peças	9045	1	3	58.50	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2948	4655	PANELA DE PRESSAO COLOR 3,00 LITROS - VERMELHA	24	24 peças	9045	1	3	58.02	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2949	9021	PANELA DE PRESSAO POLIDA 4,50 LITROS	1	- 4,50 L	\N	1	4	61.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2950	4514	PANELA DE PRESSAO POLIDA 4,50 LITROS	6	6 peças	9021	1	4	57.61	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2951	4507	PANELA DE PRESSAO POLIDA 4,50 LITROS	12	12 peças	9021	1	4	57.35	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2952	4509	PANELA DE PRESSAO POLIDA 4,50 LITROS	24	24 peças	9021	1	4	56.42	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2953	9033	PANELA DE PRESSAO ANTIADERENTE FORT FLON 4,50 LITROS	1	- 4,50 L	\N	1	4	101.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2954	4572	PANELA DE PRESSAO ANTIADERENTE FORT FLON 4,50 LITROS	6	6 peças	9033	1	4	95.55	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2955	4573	PANELA DE PRESSAO ANTIADERENTE FORT FLON 4,50 LITROS	12	12 peças	9033	1	4	94.41	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2956	9034	PANELA DE PRESSAO COLOR 4,50 LITROS - CRAQUEADA	1	- 4,50 L	\N	1	4	66.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2957	4615	PANELA DE PRESSAO COLOR 4,50 LITROS - CRAQUEADA	6	6 peças	9034	1	4	62.25	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2958	4616	PANELA DE PRESSAO COLOR 4,50 LITROS - CRAQUEADA	12	12 peças	9034	1	4	61.60	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2959	4658	PANELA DE PRESSAO COLOR 4,50 LITROS - CRAQUEADA	24	24 peças	9034	1	4	61.17	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2960	9071	PANELA DE PRESSAO COLOR 4,50 LITROS - PRETA	1	- 4,50 L	\N	1	4	66.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2961	4617	PANELA DE PRESSAO COLOR 4,50 LITROS - PRETA	6	6 peças	9071	1	4	62.25	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2962	4618	PANELA DE PRESSAO COLOR 4,50 LITROS - PRETA	12	12 peças	9071	1	4	61.60	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2963	4661	PANELA DE PRESSAO COLOR 4,50 LITROS - PRETA	24	24 peças	9071	1	4	61.17	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2964	9042	PANELA DE PRESSAO COLOR 4,50 LITROS - VERMELHA	1	- 4,50 L	\N	1	4	66.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2965	4619	PANELA DE PRESSAO COLOR 4,50 LITROS - VERMELHA	6	6 peças	9042	1	4	62.25	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2966	4620	PANELA DE PRESSAO COLOR 4,50 LITROS - VERMELHA	12	12 peças	9042	1	4	61.60	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2967	4664	PANELA DE PRESSAO COLOR 4,50 LITROS - VERMELHA	24	24 peças	9042	1	4	61.17	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2968	9022	PANELA DE PRESSAO POLIDA 7,00 LITROS	1	- 7,00 L	\N	1	5	88.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2969	4562	PANELA DE PRESSAO POLIDA 7,00 LITROS	4	4 peças	9022	1	5	85.08	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2970	4563	PANELA DE PRESSAO POLIDA 7,00 LITROS	8	8 peças	9022	1	5	84.56	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2971	4564	PANELA DE PRESSAO POLIDA 7,00 LITROS	12	12 peças	9022	1	5	83.59	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2972	9041	PANELA DE PRESSAO ANTIADERENTE FORT FLON 7,00 LITROS	1	- 7,00 L	\N	1	5	157.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2973	4627	PANELA DE PRESSAO ANTIADERENTE FORT FLON 7,00 LITROS	4	4 peças	9041	1	5	145.72	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2974	4628	PANELA DE PRESSAO ANTIADERENTE FORT FLON 7,00 LITROS	8	8 peças	9041	1	5	144.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2975	9038	PANELA DE PRESSAO COLOR 7,00 LITROS - CRAQUEADA	1	- 7,00 L	\N	1	5	97.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2976	4621	PANELA DE PRESSAO COLOR 7,00 LITROS - CRAQUEADA	4	4 peças	9038	1	5	93.08	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2977	4622	PANELA DE PRESSAO COLOR 7,00 LITROS - CRAQUEADA	8	8 peças	9038	1	5	92.65	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2978	9072	PANELA DE PRESSAO COLOR 7,00 LITROS - PRETA	1	- 7,00 L	\N	1	5	97.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2979	4623	PANELA DE PRESSAO COLOR 7,00 LITROS - PRETA	4	4 peças	9072	1	5	93.08	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2980	4624	PANELA DE PRESSAO COLOR 7,00 LITROS - PRETA	8	8 peças	9072	1	5	92.65	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2981	9048	PANELA DE PRESSAO COLOR 7,00 LITROS - VERMELHA	1	- 7,00 L	\N	1	5	97.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2982	4625	PANELA DE PRESSAO COLOR 7,00 LITROS - VERMELHA	4	4 peças	9048	1	5	93.08	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2983	4626	PANELA DE PRESSAO COLOR 7,00 LITROS - VERMELHA	8	8 peças	9048	1	5	92.65	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2984	9023	PANELA DE PRESSAO POLIDA 10,00 LITROS	1	- 10,00 L	\N	1	6	168.90	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2985	4629	PANELA DE PRESSAO POLIDA 10,00 LITROS	4	4 peças	9023	1	6	158.75	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2986	4630	PANELA DE PRESSAO POLIDA 10,00 LITROS	8	8 peças	9023	1	6	154.24	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2987	9054	PANELA DE PRESSAO COLOR 10,00 LITROS - CRAQUEADA	1	- 10,00 L	\N	1	6	200.00	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2988	4631	PANELA DE PRESSAO COLOR 10,00 LITROS - CRAQUEADA	4	4 peças	9054	1	6	182.68	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2989	4632	PANELA DE PRESSAO COLOR 10,00 LITROS - CRAQUEADA	8	8 peças	9054	1	6	179.51	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2990	9014	ASA DE BAQUELITE PP 7 LITROS	1	- 7,00 L	\N	1	7	3.20	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2991	9085	ASA DE BAQUELITE PP - 2,5 - 3 - 4,5 LITROS	1	- 2,50 - 3,00 - 4,50 L	\N	1	7	2.98	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2992	9030	ASA DE BAQUELITE PP - 10 LITROS	1	- 10,00 L	\N	1	7	3.20	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2993	9095	ASA DE BAQUELITE PP FECH EXTERNO - TODAS PPs	1	- 3,00 - 4,50 L	\N	1	7	3.88	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2994	9097	CABO DE BAQUELITE CORPO FECH EXTERNO - TODAS PPs	1	- 3,00 - 4,50 L	\N	1	7	6.73	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2995	9015	CABO DE BAQUELITE PP - 4,5 - 7 LITROS	1	- 4,50 - 7,00 L	\N	1	7	4.67	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2996	9084	CABO DE BAQUELITE PP - 2,5 - 3 LITROS	1	- 2,50 - 3,00 L	\N	1	7	3.60	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2997	9029	CABO DE BAQUELITE PP - 10 LITROS	1	- 10,00 L	\N	1	7	5.16	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2998	9096	CABO DE BAQUELITE TAMPA FECH EXTERNO - TODAS PPs	1	- 3,00 - 4,50 L	\N	1	7	10.79	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
2999	9020	CONJ DE PESO E PINO PP - TODAS PPS	1	- TODAS PP	\N	1	7	5.63	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3000	9094	CONJ DE PESO E PINO PP FECH EXTERNO - TODAS PPs	1	- 3,00 - 4,50 L	\N	1	7	9.23	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3001	9010	GUARNICAO DE SILICONE PP - 3 - 4,5 LITROS	1	- 3,00 - 4,50 L	\N	1	7	3.51	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3002	9027	GUARNICAO DE SILICONE PP - 10 LITROS	1	- 10,00 L	\N	1	7	4.37	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3003	9032	GUARNICAO DE SILICONE PP - 7 LITROS	1	- 7,00 L	\N	1	7	4.04	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3004	9083	GUARNICAO DE SILICONE PP - 2,5 LITROS	1	- 2,50 L	\N	1	7	3.20	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3005	9093	GUARNICAO DE SILICONE PP FECH EXTERNO - TODAS PPs	1	- 3,00 - 4,50 L	\N	1	7	13.29	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3011	9019	LIMPADOR PINO CENTRAL PP - TODAS PPs	1	- TODAS PP	\N	1	7	1.30	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3012	9012	VALVULA DE SEGURANCA SILICONE PP - TODAS PPs	1	- TODAS PP	\N	1	7	1.55	t	2025-12-16 22:43:56.284741+00	2026-03-16 22:19:50.4354+00
3406	4544	BALDE DE GELO REFORÇADO ESCOVADO 22 C/ CAIXA	3	3 peças	4024	12	\N	46.63	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3426	4751	CUSCUZEIRO REFORÇADO POLIDO 16	6	6 peças	3290	16	\N	36.95	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3428	4752	CUSCUZEIRO REFORÇADO POLIDO 18	6	6 peças	3051	16	\N	45.06	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3430	4758	CONJUNTO BANHO MARIA REFORÇADO POLIDO 20	6	6 peças	3117	17	\N	56.78	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3432	4543	CONJUNTO BANHO MARIA REFORÇADO POLIDO 20  C/ CAIXA	3	3 peças	4001	17	\N	61.38	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
3434	4759	CONJUNTO MULTIUSO REFORÇADO POLIDO 20	6	6 peças	3142	17	\N	68.00	t	2025-12-17 22:05:25.012965+00	2026-03-16 23:10:10.170341+00
\.


--
-- Data for Name: regioes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.regioes (id_regiao, estado, desconto_0, desconto_30, desconto_60, created_at, updated_at) FROM stdin;
1	SP	0.877	0.9094	0.9634	2025-12-15 20:20:09.63686+00	2026-03-16 22:24:19.831153+00
2	ES	0.877	0.9094	0.9634	2025-12-15 20:20:50.672891+00	2026-03-16 22:24:32.371631+00
3	MG	0.877	0.9094	0.9634	2025-12-15 20:22:36.793376+00	2026-03-16 22:24:32.962725+00
5	PR	0.877	0.9094	0.9634	2025-12-15 20:23:51.899274+00	2026-03-16 22:24:33.863846+00
6	RJ	0.877	0.9094	0.9634	2025-12-15 20:24:19.183527+00	2026-03-16 22:24:34.660417+00
\.


--
-- Data for Name: subcategoria; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subcategoria (id_subcategoria, id_categoria, nome, created_at, updated_at) FROM stdin;
1	1	PANELAS FECHAMENTO EXTERNO	2025-12-15 19:46:34.068252+00	2025-12-15 19:46:34.068252+00
2	1	PANELAS 2,5 LITROS	2025-12-15 19:46:34.068252+00	2025-12-15 19:46:34.068252+00
3	1	PANELAS 3 LITROS	2025-12-15 19:46:34.068252+00	2025-12-15 19:46:34.068252+00
4	1	PANELAS 4,5 LITROS	2025-12-15 19:46:34.068252+00	2025-12-15 19:46:34.068252+00
5	1	PANELAS 7 LITROS	2025-12-15 19:46:34.068252+00	2025-12-15 19:46:34.068252+00
6	1	PANELAS 10 LITROS	2025-12-15 19:46:34.068252+00	2025-12-15 19:46:34.068252+00
7	1	PEÇAS REPOSIÇÃO	2025-12-15 19:46:34.068252+00	2025-12-15 19:46:34.068252+00
8	2	ANTIADERENTE FORT FLON	2025-12-15 19:48:14.234584+00	2025-12-15 19:48:14.234584+00
9	2	ANTIADERENTE SUPER GRAFITE	2025-12-15 19:48:14.234584+00	2025-12-15 19:48:14.234584+00
10	2	LINHA SUPER FORTE POLIDA	2025-12-15 19:48:14.234584+00	2025-12-15 19:48:14.234584+00
11	2	LINHA EXTRA FORTE POLIDA	2025-12-15 19:48:14.234584+00	2025-12-15 19:48:14.234584+00
12	2	LINHA REFORÇADA POLIDA	2025-12-15 19:48:14.234584+00	2025-12-15 19:48:14.234584+00
13	2	LINHA HOTEL RESTAURANTE	2025-12-15 19:48:14.234584+00	2025-12-15 19:48:14.234584+00
14	3	ANTIADERENTE FORT FLON	2025-12-15 19:48:46.480684+00	2025-12-15 19:48:46.480684+00
15	3	LINHA EXTRA FORTE POLIDA	2025-12-15 19:48:46.480684+00	2025-12-15 19:48:46.480684+00
16	3	LINHA REFORÇADA POLIDA	2025-12-15 19:48:46.480684+00	2025-12-15 19:48:46.480684+00
17	3	LINHA HOTEL RESTAURANTE	2025-12-15 19:48:46.480684+00	2025-12-15 19:48:46.480684+00
18	4	ANTIADERENTE  FORT FLON	2025-12-15 19:49:23.237215+00	2025-12-15 19:49:23.237215+00
19	4	LINHA EXTRA FORTE POLIDO	2025-12-15 19:49:23.237215+00	2025-12-15 19:49:23.237215+00
20	4	LINHA REFORÇADO POLIDO	2025-12-15 19:49:23.237215+00	2025-12-15 19:49:23.237215+00
21	4	LINHA HOTEL RESTAURANTE	2025-12-15 19:49:23.237215+00	2025-12-15 19:49:23.237215+00
22	4	LINHA JOGOS COLOR	2025-12-15 19:49:23.237215+00	2025-12-15 19:49:23.237215+00
23	5	ANTIADERENTE FORT FLON	2025-12-15 19:49:59.03353+00	2025-12-15 19:49:59.03353+00
24	5	ANTIADERENTE SUPER GRAFITE	2025-12-15 19:49:59.03353+00	2025-12-15 19:49:59.03353+00
25	5	LINHA SUPER FORTE POLIDA	2025-12-15 19:49:59.03353+00	2025-12-15 19:49:59.03353+00
26	5	LINHA EXTRA FORTE POLIDA	2025-12-15 19:49:59.03353+00	2025-12-15 19:49:59.03353+00
27	5	LINHA REFORÇADA POLIDA	2025-12-15 19:49:59.03353+00	2025-12-15 19:49:59.03353+00
28	6	RETANGULARES	2025-12-15 19:50:33.004435+00	2025-12-15 19:50:33.004435+00
29	6	REDONDAS	2025-12-15 19:50:33.004435+00	2025-12-15 19:50:33.004435+00
30	6	BOLO E PUDIM	2025-12-15 19:50:33.004435+00	2025-12-15 19:50:33.004435+00
32	6	BALLERINE	2025-12-15 19:50:33.004435+00	2025-12-15 19:50:33.004435+00
33	6	PIZZA	2025-12-15 19:50:33.004435+00	2025-12-15 19:50:33.004435+00
35	6	CORAÇÃO	2025-12-15 19:50:33.004435+00	2025-12-15 19:50:33.004435+00
36	6	QUADRADA	2025-12-15 19:50:33.004435+00	2025-12-15 19:50:33.004435+00
38	9	BOJUDA	2025-12-15 19:52:08.822372+00	2025-12-15 19:52:08.822372+00
39	10	MARMITA OPERARIA REFORÇADA	2025-12-15 19:52:43.26062+00	2025-12-15 19:52:43.26062+00
40	10	JOGOS DE MARMITA	2025-12-15 19:52:43.26062+00	2025-12-15 19:52:43.26062+00
41	22	CONCHA - ESPUMADEIRA	2025-12-15 19:59:32.954953+00	2025-12-15 19:59:32.954953+00
42	22	LINHA HOTEL RESTAURANTE	2025-12-15 19:59:32.954953+00	2025-12-15 19:59:32.954953+00
44	23	VIDRO	2025-12-15 20:00:22.405758+00	2025-12-15 20:00:22.405758+00
45	23	COMUM FOSCA	2025-12-15 20:00:22.405758+00	2025-12-15 20:00:22.405758+00
46	24	JOGOS DE PANELAS	2025-12-15 20:01:01.825615+00	2025-12-15 20:01:01.825615+00
47	24	COLOR	2025-12-15 20:01:01.825615+00	2025-12-15 20:01:01.825615+00
34	6	PÃO	2025-12-15 19:50:33.004435+00	2026-03-25 14:55:51.798321+00
31	6	FUNDO REMOVÍVEL	2025-12-15 19:50:33.004435+00	2026-03-25 14:56:04.308922+00
37	9	CÔNICA	2025-12-15 19:52:08.822372+00	2026-03-25 14:56:23.505165+00
43	23	BOJUDA POLIDA	2025-12-15 20:00:22.405758+00	2026-03-25 14:57:38.760231+00
\.


--
-- Data for Name: vendedor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vendedor (id_vendedor, nome) FROM stdin;
1	Vendedor
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2025-11-11 16:32:47
20211116045059	2025-11-11 16:32:49
20211116050929	2025-11-11 16:32:52
20211116051442	2025-11-11 16:32:54
20211116212300	2025-11-11 16:32:57
20211116213355	2025-11-11 16:32:59
20211116213934	2025-11-11 16:33:01
20211116214523	2025-11-11 16:33:04
20211122062447	2025-11-11 16:33:06
20211124070109	2025-11-11 16:33:08
20211202204204	2025-11-11 16:33:10
20211202204605	2025-11-11 16:33:13
20211210212804	2025-11-11 16:33:20
20211228014915	2025-11-11 16:33:22
20220107221237	2025-11-11 16:33:24
20220228202821	2025-11-11 16:33:26
20220312004840	2025-11-11 16:33:28
20220603231003	2025-11-11 16:33:32
20220603232444	2025-11-11 16:33:34
20220615214548	2025-11-11 16:33:37
20220712093339	2025-11-11 16:33:39
20220908172859	2025-11-11 16:33:41
20220916233421	2025-11-11 16:33:43
20230119133233	2025-11-11 16:33:45
20230128025114	2025-11-11 16:33:48
20230128025212	2025-11-11 16:33:50
20230227211149	2025-11-11 16:33:53
20230228184745	2025-11-11 16:33:55
20230308225145	2025-11-11 16:33:57
20230328144023	2025-11-11 16:33:59
20231018144023	2025-11-11 16:34:02
20231204144023	2025-11-11 16:34:05
20231204144024	2025-11-11 16:34:07
20231204144025	2025-11-11 16:34:09
20240108234812	2025-11-11 16:34:12
20240109165339	2025-11-11 16:34:14
20240227174441	2025-11-11 16:34:18
20240311171622	2025-11-11 16:34:21
20240321100241	2025-11-11 16:34:25
20240401105812	2025-11-11 16:34:32
20240418121054	2025-11-11 16:34:35
20240523004032	2025-11-11 16:34:42
20240618124746	2025-11-11 16:34:44
20240801235015	2025-11-11 16:34:47
20240805133720	2025-11-11 16:34:49
20240827160934	2025-11-11 16:34:51
20240919163303	2025-11-11 16:34:54
20240919163305	2025-11-11 16:34:56
20241019105805	2025-11-11 16:34:58
20241030150047	2025-11-11 16:35:06
20241108114728	2025-11-11 16:35:09
20241121104152	2025-11-11 16:35:12
20241130184212	2025-11-11 16:35:14
20241220035512	2025-11-11 16:35:16
20241220123912	2025-11-11 16:35:19
20241224161212	2025-11-11 16:35:21
20250107150512	2025-11-11 16:35:23
20250110162412	2025-11-11 16:35:25
20250123174212	2025-11-11 16:35:27
20250128220012	2025-11-11 16:35:29
20250506224012	2025-11-11 16:35:31
20250523164012	2025-11-11 16:35:33
20250714121412	2025-11-11 16:35:35
20250905041441	2025-11-11 16:35:38
20251103001201	2025-11-17 18:44:31
20251120212548	2026-06-05 20:03:32
20251120215549	2026-06-05 20:03:32
20260218120000	2026-06-05 20:03:32
20260326120000	2026-06-05 20:03:32
20260514120000	2026-06-05 20:03:32
20260527120000	2026-06-05 20:03:32
20260528120000	2026-06-05 20:03:32
20260603120000	2026-06-05 20:03:32
20260605120000	2026-06-23 20:26:18
20260606110000	2026-06-23 20:26:18
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: -
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at, action_filter, selected_columns) FROM stdin;
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
products	products	\N	2025-11-11 18:22:52.511248+00	2025-11-11 18:22:52.511248+00	t	f	\N	\N	\N	STANDARD
\.


--
-- Data for Name: buckets_analytics; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_analytics (name, type, format, created_at, updated_at, id, deleted_at) FROM stdin;
\.


--
-- Data for Name: buckets_vectors; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.buckets_vectors (id, type, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2025-11-11 16:31:53.466493
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2025-11-11 16:31:53.489343
3	pathtoken-column	2cb1b0004b817b29d5b0a971af16bafeede4b70d	2025-11-11 16:31:53.548047
4	add-migrations-rls	427c5b63fe1c5937495d9c635c263ee7a5905058	2025-11-11 16:31:53.624998
5	add-size-functions	79e081a1455b63666c1294a440f8ad4b1e6a7f84	2025-11-11 16:31:53.631229
7	add-rls-to-buckets	e7e7f86adbc51049f341dfe8d30256c1abca17aa	2025-11-11 16:31:53.646548
8	add-public-to-buckets	fd670db39ed65f9d08b01db09d6202503ca2bab3	2025-11-11 16:31:53.651737
11	add-trigger-to-auto-update-updated_at-column	7425bdb14366d1739fa8a18c83100636d74dcaa2	2025-11-11 16:31:53.667404
12	add-automatic-avif-detection-flag	8e92e1266eb29518b6a4c5313ab8f29dd0d08df9	2025-11-11 16:31:53.675193
13	add-bucket-custom-limits	cce962054138135cd9a8c4bcd531598684b25e7d	2025-11-11 16:31:53.679541
14	use-bytes-for-max-size	941c41b346f9802b411f06f30e972ad4744dad27	2025-11-11 16:31:53.684017
15	add-can-insert-object-function	934146bc38ead475f4ef4b555c524ee5d66799e5	2025-11-11 16:31:53.732142
16	add-version	76debf38d3fd07dcfc747ca49096457d95b1221b	2025-11-11 16:31:53.736922
17	drop-owner-foreign-key	f1cbb288f1b7a4c1eb8c38504b80ae2a0153d101	2025-11-11 16:31:53.741348
18	add_owner_id_column_deprecate_owner	e7a511b379110b08e2f214be852c35414749fe66	2025-11-11 16:31:53.751838
19	alter-default-value-objects-id	02e5e22a78626187e00d173dc45f58fa66a4f043	2025-11-11 16:31:53.7591
20	list-objects-with-delimiter	cd694ae708e51ba82bf012bba00caf4f3b6393b7	2025-11-11 16:31:53.76375
21	s3-multipart-uploads	8c804d4a566c40cd1e4cc5b3725a664a9303657f	2025-11-11 16:31:53.770901
22	s3-multipart-uploads-big-ints	9737dc258d2397953c9953d9b86920b8be0cdb73	2025-11-11 16:31:53.786312
23	optimize-search-function	9d7e604cddc4b56a5422dc68c9313f4a1b6f132c	2025-11-11 16:31:53.79835
24	operation-function	8312e37c2bf9e76bbe841aa5fda889206d2bf8aa	2025-11-11 16:31:53.802625
25	custom-metadata	d974c6057c3db1c1f847afa0e291e6165693b990	2025-11-11 16:31:53.807433
37	add-bucket-name-length-trigger	3944135b4e3e8b22d6d4cbb568fe3b0b51df15c1	2025-11-11 16:31:53.884884
44	vector-bucket-type	99c20c0ffd52bb1ff1f32fb992f3b351e3ef8fb3	2025-11-17 18:44:33.364581
45	vector-buckets	049e27196d77a7cb76497a85afae669d8b230953	2025-11-17 18:44:33.378796
46	buckets-objects-grants	fedeb96d60fefd8e02ab3ded9fbde05632f84aed	2025-11-17 18:44:33.432764
47	iceberg-table-metadata	649df56855c24d8b36dd4cc1aeb8251aa9ad42c2	2025-11-17 18:44:33.438229
49	buckets-objects-grants-postgres	072b1195d0d5a2f888af6b2302a1938dd94b8b3d	2025-12-17 21:46:13.047518
2	storage-schema	f6a1fa2c93cbcd16d4e487b362e45fca157a8dbd	2025-11-11 16:31:53.496315
6	change-column-name-in-get-size	ded78e2f1b5d7e616117897e6443a925965b30d2	2025-11-11 16:31:53.640378
9	fix-search-function	af597a1b590c70519b464a4ab3be54490712796b	2025-11-11 16:31:53.656216
10	search-files-search-function	b595f05e92f7e91211af1bbfe9c6a13bb3391e16	2025-11-11 16:31:53.662592
26	objects-prefixes	215cabcb7f78121892a5a2037a09fedf9a1ae322	2025-11-11 16:31:53.811715
27	search-v2	859ba38092ac96eb3964d83bf53ccc0b141663a6	2025-11-11 16:31:53.825579
28	object-bucket-name-sorting	c73a2b5b5d4041e39705814fd3a1b95502d38ce4	2025-11-11 16:31:53.835355
29	create-prefixes	ad2c1207f76703d11a9f9007f821620017a66c21	2025-11-11 16:31:53.841037
30	update-object-levels	2be814ff05c8252fdfdc7cfb4b7f5c7e17f0bed6	2025-11-11 16:31:53.846076
31	objects-level-index	b40367c14c3440ec75f19bbce2d71e914ddd3da0	2025-11-11 16:31:53.852441
32	backward-compatible-index-on-objects	e0c37182b0f7aee3efd823298fb3c76f1042c0f7	2025-11-11 16:31:53.859092
33	backward-compatible-index-on-prefixes	b480e99ed951e0900f033ec4eb34b5bdcb4e3d49	2025-11-11 16:31:53.866033
34	optimize-search-function-v1	ca80a3dc7bfef894df17108785ce29a7fc8ee456	2025-11-11 16:31:53.867773
35	add-insert-trigger-prefixes	458fe0ffd07ec53f5e3ce9df51bfdf4861929ccc	2025-11-11 16:31:53.87345
36	optimise-existing-functions	6ae5fca6af5c55abe95369cd4f93985d1814ca8f	2025-11-11 16:31:53.878235
38	iceberg-catalog-flag-on-buckets	02716b81ceec9705aed84aa1501657095b32e5c5	2025-11-11 16:31:53.889931
39	add-search-v2-sort-support	6706c5f2928846abee18461279799ad12b279b78	2025-11-11 16:31:53.910538
40	fix-prefix-race-conditions-optimized	7ad69982ae2d372b21f48fc4829ae9752c518f6b	2025-11-11 16:31:53.918719
41	add-object-level-update-trigger	07fcf1a22165849b7a029deed059ffcde08d1ae0	2025-11-11 16:31:53.926639
42	rollback-prefix-triggers	771479077764adc09e2ea2043eb627503c034cd4	2025-11-11 16:31:53.931386
43	fix-object-level	84b35d6caca9d937478ad8a797491f38b8c2979f	2025-11-11 16:31:53.936957
48	iceberg-catalog-ids	e0e8b460c609b9999ccd0df9ad14294613eed939	2025-11-17 18:44:33.442446
50	search-v2-optimised	6323ac4f850aa14e7387eb32102869578b5bd478	2026-02-07 13:54:50.084907
51	index-backward-compatible-search	2ee395d433f76e38bcd3856debaf6e0e5b674011	2026-02-07 13:54:50.258357
52	drop-not-used-indexes-and-functions	5cc44c8696749ac11dd0dc37f2a3802075f3a171	2026-02-07 13:54:50.260614
53	drop-index-lower-name	d0cb18777d9e2a98ebe0bc5cc7a42e57ebe41854	2026-02-07 13:54:50.445594
54	drop-index-object-level	6289e048b1472da17c31a7eba1ded625a6457e67	2026-02-07 13:54:50.448402
55	prevent-direct-deletes	262a4798d5e0f2e7c8970232e03ce8be695d5819	2026-02-07 13:54:50.450396
57	s3-multipart-uploads-metadata	f127886e00d1b374fadbc7c6b31e09336aad5287	2026-04-09 22:16:42.270786
58	operation-ergonomics	00ca5d483b3fe0d522133d9002ccc5df98365120	2026-04-09 22:16:42.291579
56	fix-optimized-search-function	b823ed1e418101032fa01374edc9a436e54e3ed4	2026-02-07 13:54:50.458868
59	drop-unused-functions	38456f13e39691c2bbb4b5151d0d1cdbabd4a8c4	2026-06-05 19:45:14.742289
60	optimize-existing-functions-again	db35e1c91a9201e59f4fef8d972c2f277d68b157	2026-06-05 19:45:14.782235
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata) FROM stdin;
3875360d-97b2-458f-8c3e-8726f6c8fe47	products	produtos/shared/drive_1VG1sznpRCPkjXDqRSkOoDi9GKZ53KcxM.jpg	\N	2025-12-17 22:07:52.055851+00	2026-03-16 23:12:29.504643+00	2025-12-17 22:07:52.055851+00	{"eTag": "\\"fec70e3489adb9150d104dd7ba07d2f2\\"", "size": 499751, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:30.000Z", "contentLength": 499751, "httpStatusCode": 200}	44bdfb48-278d-48b1-b3b1-c98264b453a1	\N	{}
ce04b337-6228-421c-a178-d9fdeadd4ceb	products	produtos/shared/drive_1KnFlb90SdTcoJFpj4xOLqTTDkWb9tQMF.jpg	\N	2025-12-16 22:43:59.249619+00	2025-12-16 22:43:59.249619+00	2025-12-16 22:43:59.249619+00	{"eTag": "\\"663a43d811f14d97ceb0229a22eb4b3e\\"", "size": 128170, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:00.000Z", "contentLength": 128170, "httpStatusCode": 200}	116342cb-9759-4c9e-ade8-49401545afb0	\N	{}
f8842021-72ee-424f-ac32-fd76b6b403a5	products	produtos/shared/drive_1_lmYOi27FXlRplRmQM_2xemQKoWj4Vkc.jpg	\N	2025-12-16 23:03:16.009951+00	2025-12-16 23:03:16.009951+00	2025-12-16 23:03:16.009951+00	{"eTag": "\\"51ad3d5a06ac095d66d85a5aa303964a\\"", "size": 321562, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:03:16.000Z", "contentLength": 321562, "httpStatusCode": 200}	7bdd9c24-c7b6-4296-aa79-648723b11fc5	\N	{}
198f10f9-4b29-400b-a5f8-fce9fa74dea1	products	produtos/shared/drive_11i0h4MQMHH6obPsdtqE8Tqn8F9w7h2p0.jpg	\N	2025-12-16 22:44:01.612872+00	2025-12-16 22:44:01.612872+00	2025-12-16 22:44:01.612872+00	{"eTag": "\\"ec9881df06ae56164db50043ef20a620\\"", "size": 128160, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:02.000Z", "contentLength": 128160, "httpStatusCode": 200}	3e707717-1af3-4812-a3bf-301ff3d07a92	\N	{}
eb150a5a-6b2e-4552-9dda-017435c11ea3	products	produtos/shared/drive_1ZmRuUT3L8kfZDXPJ6I9lso3lu7QggMoY.jpg	\N	2025-12-16 22:44:03.567498+00	2025-12-16 22:44:03.567498+00	2025-12-16 22:44:03.567498+00	{"eTag": "\\"51e1c1cbdbbb0dd2eb4f7c582b974c15\\"", "size": 355091, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:04.000Z", "contentLength": 355091, "httpStatusCode": 200}	cd85fe16-b44e-418a-856b-5aecd0cf78fc	\N	{}
83d3de2a-0671-4791-aaa0-e016a28cd772	products	produtos/shared/drive_1YQK_KbXZ3r1Oo2rPY306hm5hbuRbJfyA.jpg	\N	2025-12-16 23:03:18.620335+00	2025-12-16 23:03:18.620335+00	2025-12-16 23:03:18.620335+00	{"eTag": "\\"e4d2ca0623c64b636e2db21c3d3bce0c\\"", "size": 546322, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:03:19.000Z", "contentLength": 546322, "httpStatusCode": 200}	398a0aa0-b1e2-4330-b712-84d5a1eea02b	\N	{}
6dee0561-8607-4a7f-b7ff-5934d538c64c	products	produtos/shared/drive_1w3Z06tvD_SUGAHiyM_rRTtx8aE7bNLBJ.jpg	\N	2025-12-16 22:44:07.309897+00	2025-12-16 22:44:07.309897+00	2025-12-16 22:44:07.309897+00	{"eTag": "\\"f552430bd6ac735e3830eec86b36641a\\"", "size": 157978, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:08.000Z", "contentLength": 157978, "httpStatusCode": 200}	d94de1f0-be5e-4510-946f-4698fb992a58	\N	{}
7b01e16e-f166-49ca-85cd-d3c1dae9038e	products	produtos/shared/drive_1CDh6Ca3m_ItznQSCoAG5d_viebfMsf3G.jpg	\N	2025-12-16 22:44:09.43246+00	2025-12-16 22:44:09.43246+00	2025-12-16 22:44:09.43246+00	{"eTag": "\\"0c47d8121a6ecd322ffa5d578ccda07e\\"", "size": 324189, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:10.000Z", "contentLength": 324189, "httpStatusCode": 200}	63c48fd1-efe6-4491-a4bf-373a71b8055c	\N	{}
502b5ccb-a5b8-4681-ba10-9a5b991b1fcf	products	produtos/shared/drive_1Brr1Xw2tCp4RNai0cVyf7dXa98psQu39.jpg	\N	2025-12-16 23:03:20.960476+00	2025-12-16 23:03:20.960476+00	2025-12-16 23:03:20.960476+00	{"eTag": "\\"77cba3dbaf2bfc4799ec02804269c39d\\"", "size": 490989, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:03:21.000Z", "contentLength": 490989, "httpStatusCode": 200}	d345d6f5-98bc-4545-a1a3-5ac7c11aeb07	\N	{}
2a8058a6-47e6-44b3-833d-9910f25f4d2d	products	produtos/shared/drive_1DzOSCP3kzDnWrdu3b08WTP23vmLNFfj1.jpg	\N	2025-12-16 22:44:13.131994+00	2025-12-16 22:44:13.131994+00	2025-12-16 22:44:13.131994+00	{"eTag": "\\"42a4569244bf6be129a4a5f6634c39d6\\"", "size": 167151, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:14.000Z", "contentLength": 167151, "httpStatusCode": 200}	e2ed35f3-f626-4590-87ac-850bf758c11e	\N	{}
977af6ac-4f4f-4dbb-b23d-2ef1a4260f5c	products	produtos/shared/drive_1WZqSj_inoJgU-Jh2jFmlQMymg7-XPifm.jpg	\N	2025-12-16 22:44:17.651662+00	2025-12-16 22:44:17.651662+00	2025-12-16 22:44:17.651662+00	{"eTag": "\\"a541c009ebfe9a950c072b31445036a9\\"", "size": 225243, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:18.000Z", "contentLength": 225243, "httpStatusCode": 200}	b4cc94cb-8b17-4ed4-8af3-83db4c07ea8c	\N	{}
bde3dd7c-801c-46f8-bd2e-0639f8ce4c53	products	produtos/shared/drive_1Ae9scfFhPlupwPaAP71hD35__z3ZqpkW.jpg	\N	2025-12-16 22:44:22.103919+00	2025-12-16 22:44:22.103919+00	2025-12-16 22:44:22.103919+00	{"eTag": "\\"dfc14c1b2bbe379d9cc745db5f7c2922\\"", "size": 152383, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:23.000Z", "contentLength": 152383, "httpStatusCode": 200}	fb153dbe-c4fc-4390-8bbb-f5b228860bcc	\N	{}
9c738a06-4b01-4242-84fd-3f300c3b9446	products	produtos/shared/drive_1we1oyklS9d7xFuXAab3w0o8t2_SU8D5v.jpg	\N	2025-12-16 22:44:23.900656+00	2025-12-16 22:44:23.900656+00	2025-12-16 22:44:23.900656+00	{"eTag": "\\"a2a383382281904f589462afa0833544\\"", "size": 157836, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:24.000Z", "contentLength": 157836, "httpStatusCode": 200}	e83e5ef2-d2a1-4610-9725-302522abeba3	\N	{}
74b4529a-0c64-41b3-852e-9046361e0b8b	products	produtos/shared/drive_1QSAActjD-5PRKrum18eAsbHBKvvtJpE2.jpg	\N	2025-12-16 22:44:26.093295+00	2025-12-16 22:44:26.093295+00	2025-12-16 22:44:26.093295+00	{"eTag": "\\"74e07d0fe0a4cab6de0a990228c11555\\"", "size": 333339, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:27.000Z", "contentLength": 333339, "httpStatusCode": 200}	717492be-03e4-4e9f-b06f-1f4633501318	\N	{}
ec93f98d-d1e8-4d16-8e80-d1f0fa415dd9	products	produtos/shared/drive_1Bt0QLVhGQhL57e7opAfKwQMGjI9QtKC2.jpg	\N	2025-12-16 22:44:28.210886+00	2025-12-16 22:44:28.210886+00	2025-12-16 22:44:28.210886+00	{"eTag": "\\"3b73ea6246bc6b00d050b9fcf1fe9993\\"", "size": 59048, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:29.000Z", "contentLength": 59048, "httpStatusCode": 200}	4795785e-3d63-4ec7-b280-13465abb5446	\N	{}
021436b2-684e-46ed-9611-ddb99231b131	products	produtos/shared/drive_1ztybT7pxQA4sIU2d7XsBC50T5ux9UPIz.jpg	\N	2025-12-16 23:03:23.095641+00	2025-12-16 23:03:23.095641+00	2025-12-16 23:03:23.095641+00	{"eTag": "\\"5ce6dba74e3085dcd22becd211f089d9\\"", "size": 344110, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:03:23.000Z", "contentLength": 344110, "httpStatusCode": 200}	5916e216-2cde-4848-b9f6-23f34dc07a04	\N	{}
11097500-55fa-4665-9066-8ddb678adf37	products	produtos/shared/drive_1etrmrNNxsyhfa22Q3xBt9D4LtJ1NM0gH.jpg	\N	2025-12-16 22:44:33.675751+00	2025-12-16 22:44:33.675751+00	2025-12-16 22:44:33.675751+00	{"eTag": "\\"2f583046663c31beb1e89689a66edd3b\\"", "size": 273110, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:34.000Z", "contentLength": 273110, "httpStatusCode": 200}	d0f94782-4658-48ea-9a0c-af339993c880	\N	{}
baf15c25-5305-4c83-9c6c-c63e77714115	products	produtos/shared/drive_1DHU_sm57rOxQl8zuItTgkt2zt2dYH6jk.jpg	\N	2025-12-16 22:44:37.979233+00	2025-12-16 22:44:37.979233+00	2025-12-16 22:44:37.979233+00	{"eTag": "\\"27b1ac1df949c6ffc587a3527824e64c\\"", "size": 205457, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:38.000Z", "contentLength": 205457, "httpStatusCode": 200}	579ecd1d-ab78-4f44-91bf-1ed467bb5f35	\N	{}
94dd2742-c3d3-4b40-987b-955b3c46378a	products	planilhas/produtos_atualizados_20251216_200330.xlsx	\N	2025-12-16 23:03:30.474447+00	2025-12-16 23:03:30.474447+00	2025-12-16 23:03:30.474447+00	{"eTag": "\\"3d7ce5bb9247f4e581b04f2524f826a5\\"", "size": 8655, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:03:31.000Z", "contentLength": 8655, "httpStatusCode": 200}	d20e9111-2358-4022-83a0-e5292ae13337	\N	{}
ce6c0569-fca8-4516-b44d-4b23c0bedaa2	products	produtos/shared/drive_1UKdx4WJQQFEY9WXzXG4cRCKqce0UImf6.jpg	\N	2025-12-16 22:44:42.338051+00	2025-12-16 22:44:42.338051+00	2025-12-16 22:44:42.338051+00	{"eTag": "\\"7080ded613044e215db9e9d6dd52fbae\\"", "size": 252404, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:43.000Z", "contentLength": 252404, "httpStatusCode": 200}	d4b38ed0-0795-4a7f-b776-e02bf7b38926	\N	{}
e5178427-9e89-4fd1-8a46-609544c378fc	products	produtos/shared/drive_1QTEOtLWGRhncqU-qrl6eCyf8Rcfy5DzF.jpg	\N	2025-12-17 21:55:59.263603+00	2025-12-17 21:55:59.263603+00	2025-12-17 21:55:59.263603+00	{"eTag": "\\"8610d2891c6b47afe3f7c944f1f2ac57\\"", "size": 198520, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:56:00.000Z", "contentLength": 198520, "httpStatusCode": 200}	6affb4cb-02d7-4358-9c9f-9b5c6897c92e	\N	{}
385652f1-5244-4cbf-9bde-f8168ae63463	products	produtos/shared/drive_1SHX-QMfIjxcqSWW51DeTj1QWV5CuEFZS.jpg	\N	2025-12-16 22:44:51.294534+00	2025-12-16 22:44:51.294534+00	2025-12-16 22:44:51.294534+00	{"eTag": "\\"de50faffb61475185a3bd6ed76b17416\\"", "size": 123222, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:44:52.000Z", "contentLength": 123222, "httpStatusCode": 200}	8e991c04-b813-429c-b538-2c6e1d9d8844	\N	{}
20889037-cfb8-4375-b750-a57ac8ffc6fc	products	produtos/shared/drive_1Er5f7fx75yB80Dg_3Ly3OaXGzzz-TFx5.jpg	\N	2025-12-16 22:45:02.558084+00	2025-12-16 22:45:02.558084+00	2025-12-16 22:45:02.558084+00	{"eTag": "\\"9ad445aafd9d24abfed8e8c10216d8e2\\"", "size": 178282, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:03.000Z", "contentLength": 178282, "httpStatusCode": 200}	bbfe0912-df80-417b-900b-e63e088038e1	\N	{}
8bd639dc-7167-4118-ae55-754a8d8c8850	products	produtos/shared/drive_1bvbmw3FgqsJR90O1Mm65CcpHxCmNMxJL.jpg	\N	2025-12-17 21:56:03.251122+00	2025-12-17 21:56:03.251122+00	2025-12-17 21:56:03.251122+00	{"eTag": "\\"08f5c7686d75b8ff966ed5aaf243a864\\"", "size": 199203, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:56:04.000Z", "contentLength": 199203, "httpStatusCode": 200}	205c6557-4d3b-445b-8ee7-d2559c5a46c9	\N	{}
54e4fc1b-63b9-4a56-a5c0-a1eafeba3c01	products	produtos/shared/drive_1aWd-dF7szB9ZYLFu9FjYC_DpGYnhrp06.jpg	\N	2025-12-16 22:45:07.402743+00	2025-12-16 22:45:07.402743+00	2025-12-16 22:45:07.402743+00	{"eTag": "\\"0393c0c36cabfd92274d8a4993ec979e\\"", "size": 212395, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:08.000Z", "contentLength": 212395, "httpStatusCode": 200}	b78bc334-2bc5-4650-937e-4b11f8a8efa7	\N	{}
8950c5ce-9cdd-4800-8f16-c51fc313b033	products	produtos/shared/drive_12GWv3JeOMwRUgBRgkFO-MkXBYaYThYI1.jpg	\N	2025-12-16 22:45:10.788642+00	2025-12-16 22:45:10.788642+00	2025-12-16 22:45:10.788642+00	{"eTag": "\\"864e0bc9cff29f9c175d58eb6ed06833\\"", "size": 209801, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:11.000Z", "contentLength": 209801, "httpStatusCode": 200}	5a15cf21-5b40-49f5-baa7-afc0d6e5a914	\N	{}
e3d52a79-a522-4871-b853-4f7a429919b3	products	produtos/shared/drive_1GgEThkbngNIaqtQMiXsAU1wypNsrnDLU.jpg	\N	2025-12-16 22:45:14.691424+00	2025-12-16 22:45:14.691424+00	2025-12-16 22:45:14.691424+00	{"eTag": "\\"581e7603c6fee29fc2f9d50c50bc55ea\\"", "size": 137020, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:15.000Z", "contentLength": 137020, "httpStatusCode": 200}	37e32192-8e85-40c2-96a2-adcec8f6a162	\N	{}
bc1e1f3e-7118-4673-b86b-22e39d42418d	products	produtos/shared/drive_195ByNLosHqZG80iOP8ksi6tzGe9xQRJf.jpg	\N	2025-12-16 22:45:18.5565+00	2025-12-16 22:45:18.5565+00	2025-12-16 22:45:18.5565+00	{"eTag": "\\"427ec6dd111dd5b395de856c55f2b21c\\"", "size": 253389, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:19.000Z", "contentLength": 253389, "httpStatusCode": 200}	03c705e2-3730-424f-bd56-ab7ab92f6450	\N	{}
eb42c5ee-3893-4ddc-bc64-579ea7b625be	products	produtos/shared/drive_1dgh5vbufDaLfAzWQBAoMOgxId7Ad-ssA.jpg	\N	2025-12-16 22:45:37.396201+00	2025-12-16 22:45:37.396201+00	2025-12-16 22:45:37.396201+00	{"eTag": "\\"0ed8582d3a11f89e579abfd2e7c90a7f\\"", "size": 77825, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:38.000Z", "contentLength": 77825, "httpStatusCode": 200}	959df760-352e-47cb-8e5b-dabe84563baa	\N	{}
d922bbf0-9e58-49a6-8a8a-6819fb91c4b2	products	produtos/shared/drive_1cJidTSwhIvdl1AQSY_sXy4XBezQChNx9.jpg	\N	2025-12-16 22:45:40.314437+00	2025-12-16 22:45:40.314437+00	2025-12-16 22:45:40.314437+00	{"eTag": "\\"3977cd2f5376197496992ae71cbc4e67\\"", "size": 493643, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:41.000Z", "contentLength": 493643, "httpStatusCode": 200}	f359ef25-68a8-4ddd-9e80-6408565f8edc	\N	{}
93ae8cce-c339-49c2-b10c-c57041397eb4	products	produtos/shared/drive_1zE6C837rL0CYjPJmf5Iww6t5j6BpgXm0.jpg	\N	2025-12-17 21:53:55.862737+00	2025-12-17 21:53:55.862737+00	2025-12-17 21:53:55.862737+00	{"eTag": "\\"8279730261387a9a8344e3d8e54163cb\\"", "size": 132431, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:53:56.000Z", "contentLength": 132431, "httpStatusCode": 200}	5e0123a5-349a-40a7-9672-307a1bef1d79	\N	{}
6cdae59c-ce4d-47ab-a8fe-baa10a4f834f	products	produtos/shared/drive_1bHdbHPCT28ACADnWBlTmo01k3lmFQ5La.jpg	\N	2025-12-16 22:45:42.712316+00	2025-12-16 22:45:42.712316+00	2025-12-16 22:45:42.712316+00	{"eTag": "\\"b891338138b5a7ce8f08d8c24d4ebee6\\"", "size": 526550, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:43.000Z", "contentLength": 526550, "httpStatusCode": 200}	9a1d6b6c-212e-410f-bfa7-d9c24f367f44	\N	{}
1c2050a3-c211-4ad0-80f9-267a81f8d5bc	products	produtos/shared/drive_1898v58_4BFt7mcfpB38--bvh3o9slG03.jpg	\N	2025-12-16 22:45:44.408724+00	2025-12-16 22:45:44.408724+00	2025-12-16 22:45:44.408724+00	{"eTag": "\\"8d17fbeb60bfd6c9faa8137c88959cf3\\"", "size": 98663, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:45.000Z", "contentLength": 98663, "httpStatusCode": 200}	9756588a-e42b-49d4-b210-a8bd3578777c	\N	{}
8674292b-b4e9-4c55-b70d-0b396d648d73	products	produtos/shared/drive_1ccCC8Nj8_TqNDf5gHESCUnJUdLO3NW2x.jpg	\N	2025-12-17 21:54:02.28231+00	2025-12-17 21:54:02.28231+00	2025-12-17 21:54:02.28231+00	{"eTag": "\\"7759bb7b82a8a76715a9bafe75d992de\\"", "size": 173404, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:03.000Z", "contentLength": 173404, "httpStatusCode": 200}	8535523f-75b2-4c45-8556-d4cd6253329e	\N	{}
5ba36d6e-0fba-4e67-958a-10569e300b36	products	produtos/shared/drive_12uGSQyOVSme4gDDBPNomJgBrqEjNaUFg.jpg	\N	2025-12-16 22:45:47.108838+00	2025-12-16 22:45:47.108838+00	2025-12-16 22:45:47.108838+00	{"eTag": "\\"c43e58679e4452038cf35c7a82061f40\\"", "size": 432049, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:48.000Z", "contentLength": 432049, "httpStatusCode": 200}	751c785b-29cb-4c8c-9bcc-835c86131c5f	\N	{}
befe879e-afb8-4ebd-bf62-0f0c272d0cbf	products	produtos/shared/drive_1XTHGsiEO3pXFJ_mu75JkwgN5Glf8eHMp.jpg	\N	2025-12-16 22:45:49.135582+00	2025-12-16 22:45:49.135582+00	2025-12-16 22:45:49.135582+00	{"eTag": "\\"0f963a7e573ae4ac19c51768c77b4512\\"", "size": 164635, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:50.000Z", "contentLength": 164635, "httpStatusCode": 200}	0a015e69-5786-4767-919a-fd017d3df3c3	\N	{}
4a4331aa-062b-4f48-b0c0-6540b3de21e7	products	produtos/shared/drive_1JM2k_lN_DYxthTglFugjKyY0b1yEPu2x.jpg	\N	2025-12-17 21:54:07.227788+00	2025-12-17 21:54:07.227788+00	2025-12-17 21:54:07.227788+00	{"eTag": "\\"f69083fc30bfee0cc957cb81bbda40ca\\"", "size": 154197, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:08.000Z", "contentLength": 154197, "httpStatusCode": 200}	61070281-dd53-40db-9413-8335eb769328	\N	{}
86787dd9-6f46-4b07-bf7f-dbb4d674c930	products	produtos/shared/drive_1YDkmP7ap2Xje6e2ifJW3qdoLn-ZhS1XU.jpg	\N	2025-12-16 22:45:51.2011+00	2025-12-16 22:45:51.2011+00	2025-12-16 22:45:51.2011+00	{"eTag": "\\"09f71fd7c3bc98d40b2519e649951fe5\\"", "size": 546843, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:52.000Z", "contentLength": 546843, "httpStatusCode": 200}	001c69bf-fd88-46fc-abb9-4f324d653815	\N	{}
c833fa1d-3125-4888-be69-4794e06b67d2	products	produtos/shared/drive_1D8qx7XmTKUc1Np_KpKDX0PrWpfH5aXSH.jpg	\N	2025-12-16 22:45:53.411327+00	2025-12-16 22:45:53.411327+00	2025-12-16 22:45:53.411327+00	{"eTag": "\\"0b0c2ba7aa8b4e2542fd9c0e30296c27\\"", "size": 118528, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:54.000Z", "contentLength": 118528, "httpStatusCode": 200}	0e45fdf4-5370-4033-a682-f64f6590ae60	\N	{}
e0bb60e8-f35a-4d90-8fdb-2c33e24258f5	products	produtos/shared/drive_1qKYPYk4IoBnrBuVHbUCHccYTy6e-ZP61.jpg	\N	2025-12-16 22:45:56.950851+00	2025-12-16 22:45:56.950851+00	2025-12-16 22:45:56.950851+00	{"eTag": "\\"54b502537571709c08d1b484c4517e69\\"", "size": 493754, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:57.000Z", "contentLength": 493754, "httpStatusCode": 200}	8c78f93c-b507-43a7-ab83-456fe617c0e6	\N	{}
a8215969-1ef9-451b-9671-afad97f7de93	products	produtos/shared/drive_1cv3SoXUlGEeNLKmvnd4TfBC9iY6zeUp6.jpg	\N	2025-12-16 22:45:58.977029+00	2025-12-16 22:45:58.977029+00	2025-12-16 22:45:58.977029+00	{"eTag": "\\"3a9ddb314019c42f8c5ca8fa1aa443be\\"", "size": 32404, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:45:59.000Z", "contentLength": 32404, "httpStatusCode": 200}	f66b3ba0-814e-4dd6-b809-2646ebc323a2	\N	{}
0b3cab08-a411-45b5-8b4c-6bfabb30f079	products	produtos/shared/drive_1o1vit_FLlsMeR-67eo_HqTL9zjogHQ9R.jpg	\N	2025-12-16 22:46:03.405082+00	2025-12-16 22:46:03.405082+00	2025-12-16 22:46:03.405082+00	{"eTag": "\\"7545a75df1d6ce6d4dce31358c816b0b\\"", "size": 112590, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:46:04.000Z", "contentLength": 112590, "httpStatusCode": 200}	1e18b4a4-7be7-4a6d-ad93-40384f6f5f57	\N	{}
1f49a33c-4ba0-41df-9ae9-baa22dbb7a80	products	produtos/shared/drive_1uX6MsIV6b1vT2n3kYPiZDM60_s1Odxvq.jpg	\N	2025-12-17 21:54:11.95292+00	2025-12-17 21:54:11.95292+00	2025-12-17 21:54:11.95292+00	{"eTag": "\\"2b9251e385a9c2955891973e8bf04c2f\\"", "size": 142874, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:12.000Z", "contentLength": 142874, "httpStatusCode": 200}	2499ed2e-b040-4aa7-b306-a4a30f036fd9	\N	{}
40b440be-716c-4967-9fe4-d42f4f05313f	products	planilhas/produtos_atualizados_20251216_194619.xlsx	\N	2025-12-16 22:46:19.675362+00	2025-12-16 22:46:19.675362+00	2025-12-16 22:46:19.675362+00	{"eTag": "\\"a9eee5adc607976e4f54d7629fab796a\\"", "size": 13306, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:46:20.000Z", "contentLength": 13306, "httpStatusCode": 200}	29d65ed7-8033-4ae2-80f7-12f74bc19f94	\N	{}
3b848692-e1a4-41a7-a9aa-80ccc1603f30	products	produtos/shared/drive_1q002d2QSr5uCYAQV11OETO_sIiba--vS.jpg	\N	2025-12-17 21:54:14.897397+00	2025-12-17 21:54:14.897397+00	2025-12-17 21:54:14.897397+00	{"eTag": "\\"abb8f86f19cfe5d59de6599b732adedf\\"", "size": 123106, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:15.000Z", "contentLength": 123106, "httpStatusCode": 200}	69c378a2-6704-4f77-8df3-96896b667524	\N	{}
b4d08474-d96d-4891-9a28-06ce66d4904d	products	produtos/shared/drive_1iE0pYGV1PZH4WsaHbC-qH2chsccn_SPY.jpg	\N	2025-12-17 22:08:13.454419+00	2026-03-16 23:12:51.963462+00	2025-12-17 22:08:13.454419+00	{"eTag": "\\"d446d327a97d1e3b9fbf97f3e68d0e6c\\"", "size": 441594, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:52.000Z", "contentLength": 441594, "httpStatusCode": 200}	21a414df-dccd-481d-90e6-13d9be11e03b	\N	{}
edce3909-7a97-4ba6-9ed9-39ed685707c8	products	produtos/shared/drive_1rYuhuj7TrfxqwIMP-NWhtB8MKdC64A_s.jpg	\N	2025-12-17 21:54:18.700559+00	2025-12-17 21:54:18.700559+00	2025-12-17 21:54:18.700559+00	{"eTag": "\\"36039d0241e4d17fd149959fc908ac2f\\"", "size": 240271, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:19.000Z", "contentLength": 240271, "httpStatusCode": 200}	69fddd2d-379a-4d4a-ad87-b25036768024	\N	{}
bd270703-d28a-4801-8820-a1829729ec82	products	produtos/shared/drive_12O6yhoDkaeRvcGfb-kFTxO-lfYziqwId.jpg	\N	2025-12-17 21:54:22.812522+00	2025-12-17 21:54:22.812522+00	2025-12-17 21:54:22.812522+00	{"eTag": "\\"2011edaa1d579ab67816c4578aa72b15\\"", "size": 159036, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:23.000Z", "contentLength": 159036, "httpStatusCode": 200}	e346be40-efca-4461-9991-7f6a6f6d41de	\N	{}
300d5dcf-87a0-4635-b2ac-2a20fec1abd0	products	produtos/shared/drive_15nApI_PULYh67QaWppgIFC_5BDvTE7T1.jpg	\N	2025-12-17 21:54:26.170478+00	2025-12-17 21:54:26.170478+00	2025-12-17 21:54:26.170478+00	{"eTag": "\\"a4cbc265d110b5f56f43d0be3c1550b4\\"", "size": 167662, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:27.000Z", "contentLength": 167662, "httpStatusCode": 200}	ea780bbb-3f5d-4766-a569-0ccfb959a45c	\N	{}
139031ea-05a7-4122-ae4e-c1664866828f	products	produtos/shared/drive_1HxCbFcwslt1MnCzZKlGcHYHTWR0_abHF.jpg	\N	2025-12-17 21:54:29.395676+00	2025-12-17 21:54:29.395676+00	2025-12-17 21:54:29.395676+00	{"eTag": "\\"3adab5ac377e074d1190225a5a3c0272\\"", "size": 176524, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:30.000Z", "contentLength": 176524, "httpStatusCode": 200}	412dd0d7-2e95-4001-83c2-6bbdfe7049ad	\N	{}
9c534e99-0753-462d-a2c6-924bb6348f5d	products	produtos/shared/drive_1WJaBFiaO3py4Lx2VaPWNHZ8EJ0rhHKNf.jpg	\N	2025-12-17 21:54:32.39905+00	2025-12-17 21:54:32.39905+00	2025-12-17 21:54:32.39905+00	{"eTag": "\\"2da20149ec335b62c6730ddd98881294\\"", "size": 130177, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:33.000Z", "contentLength": 130177, "httpStatusCode": 200}	6b229235-a55e-425e-ac1f-97a49d26de5b	\N	{}
565751bd-e924-4243-a5ef-6fc185e2b184	products	produtos/shared/drive_1vKQVV3LlxkcqfSYkfyCkKqdh0EW4bktv.jpg	\N	2025-12-17 21:54:37.900688+00	2025-12-17 21:54:37.900688+00	2025-12-17 21:54:37.900688+00	{"eTag": "\\"cee58b32ed69446526bcd3172afa393b\\"", "size": 88074, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:38.000Z", "contentLength": 88074, "httpStatusCode": 200}	c259a8e3-e445-42f7-bf71-7902415542de	\N	{}
4b1c8f6e-76ac-488f-bfba-44cb0c3b23fc	products	produtos/shared/drive_1_0RlS11QY8Q0kAORE8wRQ8NXwC876gtU.jpg	\N	2025-12-17 21:54:40.957955+00	2025-12-17 21:54:40.957955+00	2025-12-17 21:54:40.957955+00	{"eTag": "\\"3c4f48a2ea26a68f56fb227b565fea63\\"", "size": 178186, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:41.000Z", "contentLength": 178186, "httpStatusCode": 200}	1ec7c469-399e-4950-9599-9f52b861827b	\N	{}
f16749bf-977c-4b61-8f2b-4a121dad9ae5	products	produtos/shared/drive_1ovCP2r-FfJbeXB6DpfpQ7QoK2K-YsdEW.jpg	\N	2025-12-17 21:54:46.961289+00	2025-12-17 21:54:46.961289+00	2025-12-17 21:54:46.961289+00	{"eTag": "\\"2456242cce83b5b164fd847559f989b1\\"", "size": 186166, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:47.000Z", "contentLength": 186166, "httpStatusCode": 200}	5bfe4a18-dfaa-4ea3-abc9-2e5bc46a11b9	\N	{}
d11b5438-0e90-4f09-a919-906e95621ec7	products	produtos/shared/drive_1m3Mgbbqb1L2zigRi5vFIyp7kpfh7j-8j.jpg	\N	2025-12-16 22:56:41.61729+00	2025-12-16 22:56:41.61729+00	2025-12-16 22:56:41.61729+00	{"eTag": "\\"d0b0ec0cad7683110e9f7a482e0568b0\\"", "size": 187908, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:56:42.000Z", "contentLength": 187908, "httpStatusCode": 200}	40b4ac92-b47d-43bc-916e-ca2b3ee43d8a	\N	{}
a880f9a9-5196-43d8-afaf-3a0d7a311227	products	produtos/shared/drive_1JezFlf9jc1bzJho6WeuBUwlGDnrlNL6D.jpg	\N	2025-12-16 22:56:47.109431+00	2025-12-16 22:56:47.109431+00	2025-12-16 22:56:47.109431+00	{"eTag": "\\"e8b29fccd2ae87124f84f9e93f72f63b\\"", "size": 183127, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:56:47.000Z", "contentLength": 183127, "httpStatusCode": 200}	5ac1fbcc-21b7-40a1-87a4-b4aa28d57663	\N	{}
1d610019-227a-4c48-ae5d-937dcdcb475f	products	produtos/shared/drive_1p7lExnu21q-lwTDjjjCPIvymyc79u3DD.jpg	\N	2025-12-17 21:54:53.378203+00	2025-12-17 21:54:53.378203+00	2025-12-17 21:54:53.378203+00	{"eTag": "\\"891b1bcdb17e6199cd7a677088ea9b4a\\"", "size": 185670, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:54.000Z", "contentLength": 185670, "httpStatusCode": 200}	3593e613-79ea-44a4-b0c6-800cf30fc58a	\N	{}
15d324e9-c91c-43c0-8cb6-46b6c6d2df4b	products	produtos/shared/drive_1AffV03fOqj6fYJswWk_s331lyi66Z1s9.jpg	\N	2025-12-16 22:56:53.252764+00	2025-12-16 22:56:53.252764+00	2025-12-16 22:56:53.252764+00	{"eTag": "\\"f7f54d09c976364771be6d6a9ecab23c\\"", "size": 196700, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:56:54.000Z", "contentLength": 196700, "httpStatusCode": 200}	49331a6b-c1c3-485d-9594-3c75fd6b53e3	\N	{}
1a680e4d-ae08-4285-80f3-5c493c8793f1	products	produtos/shared/drive_1pbEAkWiAOoPx7DECnzMfFDlYC56a0I-6.jpg	\N	2025-12-16 22:56:57.01253+00	2025-12-16 22:56:57.01253+00	2025-12-16 22:56:57.01253+00	{"eTag": "\\"76d10126dbb11fe5709962370daf7771\\"", "size": 198889, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:56:57.000Z", "contentLength": 198889, "httpStatusCode": 200}	7263a017-a771-486e-947c-070af48091f4	\N	{}
c54ed683-7614-47c6-a845-720b40bd9d56	products	produtos/shared/drive_15Zr1R1WqbH3sDnyJlaWnm0gvrxJnZQP-.jpg	\N	2025-12-17 21:54:57.108585+00	2025-12-17 21:54:57.108585+00	2025-12-17 21:54:57.108585+00	{"eTag": "\\"398b77126d53de457d6d8fb0442cbd9f\\"", "size": 173389, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:54:58.000Z", "contentLength": 173389, "httpStatusCode": 200}	c68dde19-795a-482c-a4cb-d2fcec27e0c9	\N	{}
1f75dab4-3ddf-4574-93c3-6455285fe7bd	products	produtos/shared/drive_1lLe9F3xDvJWOxhAxnh1BRi7LL8Ea9DTF.jpg	\N	2025-12-16 22:57:02.367336+00	2025-12-16 22:57:02.367336+00	2025-12-16 22:57:02.367336+00	{"eTag": "\\"8a1589faafce8fa97a1a4287a229725f\\"", "size": 159083, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:57:03.000Z", "contentLength": 159083, "httpStatusCode": 200}	b788cd32-3fe7-421e-8898-d55b33777fc2	\N	{}
968b48f7-a0ea-4db7-bfd3-140fdf309bd9	products	produtos/shared/drive_1XHO2TlAkMl5EdHsqnUgNPd0iyKeYF_ES.jpg	\N	2025-12-16 22:57:06.025641+00	2025-12-16 22:57:06.025641+00	2025-12-16 22:57:06.025641+00	{"eTag": "\\"b1059041712d3122211b8c3038671656\\"", "size": 207862, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:57:06.000Z", "contentLength": 207862, "httpStatusCode": 200}	d3059194-abca-4321-8293-a015c2f0cf89	\N	{}
4f2bd9b1-c6a8-410c-8156-853329870070	products	produtos/shared/drive_1ivQPL7ztQQA65lL--qVViRUotW3Rsq0k.jpg	\N	2025-12-16 22:57:14.218036+00	2025-12-16 22:57:14.218036+00	2025-12-16 22:57:14.218036+00	{"eTag": "\\"81bb23186de408ad718561e1cfc7c555\\"", "size": 154998, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:57:15.000Z", "contentLength": 154998, "httpStatusCode": 200}	088fe98c-887d-41ec-9543-1839a5baea05	\N	{}
fa31ff70-b693-4428-8636-41ca12c5b982	products	produtos/shared/drive_1PqZaU8s-iIHLeJoHPVIyjFLuIxx-F3Z8.jpg	\N	2025-12-16 22:57:20.762293+00	2025-12-16 22:57:20.762293+00	2025-12-16 22:57:20.762293+00	{"eTag": "\\"a4b502fa450738b6ec9853aec4a00bfe\\"", "size": 221470, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:57:21.000Z", "contentLength": 221470, "httpStatusCode": 200}	efe1a5a8-5f11-404a-9770-3742fb6ca232	\N	{}
04563013-935a-4246-9305-cfeb3dd6fa8f	products	produtos/shared/drive_1WiqtiFN41tFhTz1bo9AEMobkAlvhc8G1.jpg	\N	2025-12-16 22:57:26.595051+00	2025-12-16 22:57:26.595051+00	2025-12-16 22:57:26.595051+00	{"eTag": "\\"042690fb7fb9c89dc62fd3a1795a2a4e\\"", "size": 193837, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:57:27.000Z", "contentLength": 193837, "httpStatusCode": 200}	5bbd012c-0378-472d-9461-3cfb79685e9d	\N	{}
95609727-2c26-4c85-b243-c25d389a866b	products	produtos/shared/drive_1zm-vjLjhfI-svGjpJy9a83fUjQG83LEK.jpg	\N	2025-12-16 22:57:28.602999+00	2025-12-16 22:57:28.602999+00	2025-12-16 22:57:28.602999+00	{"eTag": "\\"0f632f5202eeae6484401a3dfa039ee1\\"", "size": 142053, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:57:29.000Z", "contentLength": 142053, "httpStatusCode": 200}	359666b4-d857-49a5-98c1-50d53907a41c	\N	{}
dc168a0c-045b-4050-b87c-64f034dc3749	products	planilhas/produtos_atualizados_20251216_195742.xlsx	\N	2025-12-16 22:57:43.07855+00	2025-12-16 22:57:43.07855+00	2025-12-16 22:57:43.07855+00	{"eTag": "\\"eae83dc92325ec6ff1233b898b153906\\"", "size": 9986, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:57:44.000Z", "contentLength": 9986, "httpStatusCode": 200}	6190e6f4-9852-47d8-902b-b7ffb77c5576	\N	{}
b33118d6-78de-43f9-905b-8a8ae773a3d4	products	produtos/shared/drive_1se_Tk8MjK5fSXGiN3MB8dwCoYRZKDSpP.jpg	\N	2025-12-17 21:55:00.275304+00	2025-12-17 21:55:00.275304+00	2025-12-17 21:55:00.275304+00	{"eTag": "\\"9f4fb2adca96be287931ea486b82cd23\\"", "size": 211938, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:01.000Z", "contentLength": 211938, "httpStatusCode": 200}	1859c76b-5d9d-48ee-b149-0bc76bf4e7fb	\N	{}
4c3488f5-bdf9-481d-9738-4035c59c8504	products	produtos/shared/drive_13eLi1Lexa1lkRggF2Ql-FCfJMB0wbJok.jpg	\N	2025-12-17 21:55:06.273148+00	2025-12-17 21:55:06.273148+00	2025-12-17 21:55:06.273148+00	{"eTag": "\\"7e14b7ddcd7f3c9764556a50dae3b3f6\\"", "size": 177325, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:07.000Z", "contentLength": 177325, "httpStatusCode": 200}	099d1a0c-4921-4172-9e11-0cf018c8c724	\N	{}
89e9aa60-911e-4058-9ff6-a829cbcb8605	products	produtos/shared/drive_1PTEsh8nPay2t35xFgwMMtro6KN2FjCeH.jpg	\N	2025-12-17 22:08:16.23023+00	2026-03-16 23:12:54.39478+00	2025-12-17 22:08:16.23023+00	{"eTag": "\\"d0438cf046b2629fe227083552b70618\\"", "size": 325539, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:55.000Z", "contentLength": 325539, "httpStatusCode": 200}	d5ec3d4c-a5b3-4a95-a676-df15618f7d77	\N	{}
b9723a25-f87f-48ae-bf42-bbeb496b2e1d	products	produtos/shared/drive_1qLEkVYax-JnSlKKcWY3SHUQq_jFBHPQJ.jpg	\N	2025-12-17 21:55:11.436112+00	2025-12-17 21:55:11.436112+00	2025-12-17 21:55:11.436112+00	{"eTag": "\\"49823a28644473b45e2e371de35acdc9\\"", "size": 264817, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:12.000Z", "contentLength": 264817, "httpStatusCode": 200}	92b614de-39ce-4467-b0bc-537fde0b47be	\N	{}
589e37c0-911e-4445-9a8e-74ab9002172a	products	produtos/shared/drive_1K3hX7k88FipY3fLNzpGKP5dtDm_ysUs9.jpg	\N	2025-12-17 21:55:14.875837+00	2025-12-17 21:55:14.875837+00	2025-12-17 21:55:14.875837+00	{"eTag": "\\"9d266cef1e45b2b880c6656f935b0894\\"", "size": 254858, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:15.000Z", "contentLength": 254858, "httpStatusCode": 200}	b1fd522f-6f9a-4972-86fc-989e8c219fe0	\N	{}
9c217916-572f-4097-9609-1416f377033c	products	produtos/shared/drive_1tK1dW86p9O0oL_FD9p163f_xZHjazrYC.jpg	\N	2025-12-17 21:55:19.479324+00	2025-12-17 21:55:19.479324+00	2025-12-17 21:55:19.479324+00	{"eTag": "\\"4bccfd4cafa7522426daa1c7c5a836d9\\"", "size": 274153, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:20.000Z", "contentLength": 274153, "httpStatusCode": 200}	4d8baca5-2a67-4f95-9b02-da23fe898c71	\N	{}
1d16adfa-4c53-48af-aa1a-4ee331f93221	products	produtos/shared/drive_1IfU8QBmFAombWqW_3-IINipnSbfxiJe9.jpg	\N	2025-12-17 21:55:22.652507+00	2025-12-17 21:55:22.652507+00	2025-12-17 21:55:22.652507+00	{"eTag": "\\"79c004bb14d12ccea60c769698d209a9\\"", "size": 253679, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:23.000Z", "contentLength": 253679, "httpStatusCode": 200}	667a4bef-2b83-45d8-8fcf-82a102821d0a	\N	{}
a703677b-7064-41fb-9026-2d16aabcadf1	products	produtos/shared/drive_1DQapGZ2GhTtYu4gvZSZbiZqQwaqiOygW.jpg	\N	2025-12-17 21:55:28.762031+00	2025-12-17 21:55:28.762031+00	2025-12-17 21:55:28.762031+00	{"eTag": "\\"c5950123cef3887c00243be5544ee657\\"", "size": 261264, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:29.000Z", "contentLength": 261264, "httpStatusCode": 200}	235c3ba2-9c85-480e-b466-9674aac314fc	\N	{}
ce8ba7a7-99aa-4519-95af-203d5e35ee11	products	produtos/shared/drive_1IWZORDEI-ixXllNrTbNJjmL5VsV1mVNh.jpg	\N	2025-12-17 21:55:33.311989+00	2025-12-17 21:55:33.311989+00	2025-12-17 21:55:33.311989+00	{"eTag": "\\"716245d73e3bb4b5e04a4b2397db6fe9\\"", "size": 241695, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:34.000Z", "contentLength": 241695, "httpStatusCode": 200}	1765eb2c-dfff-4b32-b3ea-28bbdd0bf118	\N	{}
90db899f-f5b8-4df4-8089-93e3bb2ebab3	products	produtos/shared/drive_1ucroNKI5EhwhHlACdYSWH4_ktCbCBllE.jpg	\N	2025-12-17 21:55:37.862874+00	2025-12-17 21:55:37.862874+00	2025-12-17 21:55:37.862874+00	{"eTag": "\\"12f03dcaf8143c2af97a414d6a0464bd\\"", "size": 267472, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:38.000Z", "contentLength": 267472, "httpStatusCode": 200}	c1954e5f-2c96-4b0d-8f62-d5548c5deeb8	\N	{}
f074c96d-3a12-4b26-8d7c-757fae7c5601	products	produtos/shared/drive_1uXT0Qoi1x1B6_FSGNUxEiVWqePJHGDTr.jpg	\N	2025-12-17 21:55:42.017014+00	2025-12-17 21:55:42.017014+00	2025-12-17 21:55:42.017014+00	{"eTag": "\\"52d249fb472802d0a35f49bf1b64ac0b\\"", "size": 160850, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:42.000Z", "contentLength": 160850, "httpStatusCode": 200}	8100f18b-3efb-402d-b0d2-3857e375dbdb	\N	{}
ff6e3f70-4e06-42c3-8e5f-16ba64ceeb90	products	produtos/shared/drive_1izGlXB5lsU7Fat3eLVJmGl8RyT15_ZcW.jpg	\N	2025-12-16 22:59:34.210169+00	2025-12-16 22:59:34.210169+00	2025-12-16 22:59:34.210169+00	{"eTag": "\\"1ece62f35ceea9c23046e483df213c4d\\"", "size": 192048, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:59:35.000Z", "contentLength": 192048, "httpStatusCode": 200}	07947b8d-f6e6-40be-95c7-2a2073f8aec6	\N	{}
5c7c15f5-54d7-4945-8ec3-bd3e1f04268c	products	produtos/shared/drive_1gV78FTnVkBrWaj78azKnrHJ8KOeSMExL.jpg	\N	2025-12-17 21:55:46.750707+00	2025-12-17 21:55:46.750707+00	2025-12-17 21:55:46.750707+00	{"eTag": "\\"29dc7ab69c488d4615dee510432a224d\\"", "size": 182116, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:47.000Z", "contentLength": 182116, "httpStatusCode": 200}	2259f44a-3e31-42f0-88ba-474b3e33de44	\N	{}
9681669b-e73f-4901-b382-028569981df3	products	produtos/shared/drive_1u6KMzby5uopq0ecmsX-uYH0gZp9RbVQs.jpg	\N	2025-12-16 22:59:37.729124+00	2025-12-16 22:59:37.729124+00	2025-12-16 22:59:37.729124+00	{"eTag": "\\"6b7868301ae21c3ebe48c153fa3ec5f1\\"", "size": 188947, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:59:38.000Z", "contentLength": 188947, "httpStatusCode": 200}	5e27e7bf-cc2f-464e-b3e6-83a36f1b007d	\N	{}
68b2cdff-9448-44e5-b8f3-3ad1d9e3f7a0	products	produtos/shared/drive_1bp0zzZe6cCuoGYafoQk4GDMnMtgcaKi0.jpg	\N	2025-12-16 22:59:40.746453+00	2025-12-16 22:59:40.746453+00	2025-12-16 22:59:40.746453+00	{"eTag": "\\"7e0ca17c66b1cf19f2c72a0b2f1d89c5\\"", "size": 219384, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:59:41.000Z", "contentLength": 219384, "httpStatusCode": 200}	2e7b0a24-d85b-423a-bf55-31ad380635ae	\N	{}
e4cb4741-7a30-46c7-97b9-a7a42f787112	products	produtos/shared/drive_1a8YMaJhxX5DelmZg89HI7_mm1xGa5B4c.jpg	\N	2025-12-17 21:55:51.625924+00	2025-12-17 21:55:51.625924+00	2025-12-17 21:55:51.625924+00	{"eTag": "\\"2dbda393d6ea2aa3bfc0bd6f44cd324a\\"", "size": 152674, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:52.000Z", "contentLength": 152674, "httpStatusCode": 200}	6282a2cf-ccaa-4835-93fd-a33270511a10	\N	{}
b8966d57-dc39-4121-b8a1-212c94d9eb4f	products	produtos/shared/drive_1XPNZw3ILSMNi1E_WrrVtkkcTi57Khy5h.jpg	\N	2025-12-16 22:59:43.878954+00	2025-12-16 22:59:43.878954+00	2025-12-16 22:59:43.878954+00	{"eTag": "\\"9ebdc9f287b329328dbdb483d8014e17\\"", "size": 334473, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:59:44.000Z", "contentLength": 334473, "httpStatusCode": 200}	d36eda1c-defa-4000-8600-9b1eb5f86487	\N	{}
3cb60e18-3434-4bd0-bd02-f4b4fddc5f9e	products	planilhas/produtos_atualizados_20251216_195950.xlsx	\N	2025-12-16 22:59:50.923959+00	2025-12-16 22:59:50.923959+00	2025-12-16 22:59:50.923959+00	{"eTag": "\\"3ae02b7d7558dd2caef49ea04d3ad0dd\\"", "size": 6635, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2025-12-16T22:59:51.000Z", "contentLength": 6635, "httpStatusCode": 200}	9fb9496c-79aa-44f1-a2e0-dbad8729d777	\N	{}
8d194c64-35e2-44d5-9e57-7d0ed97ba50b	products	produtos/shared/drive_1AJBgvVClkqmR3TpvgEDGHtnG8s-r8zDE.jpg	\N	2025-12-17 21:55:54.875907+00	2025-12-17 21:55:54.875907+00	2025-12-17 21:55:54.875907+00	{"eTag": "\\"7bbe5f0778ad907eace92a27175ec7dc\\"", "size": 149071, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:55:55.000Z", "contentLength": 149071, "httpStatusCode": 200}	eb2b6e29-ecfe-4ad6-882f-833308f5d248	\N	{}
c59b46f9-e191-40e2-90fb-d0a538af5471	products	produtos/shared/drive_1OVakRBzhhGETngldlZHLSqGy_b9OUMA0.jpg	\N	2025-12-16 23:02:46.612698+00	2025-12-16 23:02:46.612698+00	2025-12-16 23:02:46.612698+00	{"eTag": "\\"f588c929a2755a68eba68c1a10e4f4fa\\"", "size": 239226, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:02:47.000Z", "contentLength": 239226, "httpStatusCode": 200}	6a277a6d-6984-4d2b-bcbe-afc25fc348b7	\N	{}
b433caac-58f9-4475-a7e5-6a2a75d7f9c6	products	produtos/shared/drive_1rkkqesWXo4ahfDzeypNfdnUs68olXdrq.jpg	\N	2025-12-16 23:02:50.611004+00	2025-12-16 23:02:50.611004+00	2025-12-16 23:02:50.611004+00	{"eTag": "\\"bf01e402276a353699ca7887b2208d18\\"", "size": 174221, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:02:51.000Z", "contentLength": 174221, "httpStatusCode": 200}	6906a89f-af02-484b-bd7c-2b935dfd99c6	\N	{}
576af81d-7de9-4aa6-8633-0017685e0172	products	produtos/shared/drive_1zBYTnpiYHfpL5-PVkzmr4Rf4HOA39v2k.jpg	\N	2025-12-16 23:02:55.339717+00	2025-12-16 23:02:55.339717+00	2025-12-16 23:02:55.339717+00	{"eTag": "\\"f224b185221d1b13ecbf407506e8ea18\\"", "size": 381926, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:02:56.000Z", "contentLength": 381926, "httpStatusCode": 200}	124b9f2f-e47c-413b-817d-d0cbd6853372	\N	{}
d3884978-992e-453a-b6ce-ec8af4e140de	products	produtos/shared/drive_1sY54wm0Dl2uoVCwwp3JaUZKdRT2ccsLm.jpg	\N	2025-12-16 23:02:59.159125+00	2025-12-16 23:02:59.159125+00	2025-12-16 23:02:59.159125+00	{"eTag": "\\"58171c9fc14beef908dc14e6158cb385\\"", "size": 187609, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:03:00.000Z", "contentLength": 187609, "httpStatusCode": 200}	b8d134c8-50ca-4c97-a1e9-4ce9861d0123	\N	{}
843d65ba-b221-4f3b-95eb-3ae5e93c99cf	products	produtos/shared/drive_1CDJsQp1kmpq-BkocNHzRsLwUOVWIu8ma.jpg	\N	2025-12-16 23:03:02.325405+00	2025-12-16 23:03:02.325405+00	2025-12-16 23:03:02.325405+00	{"eTag": "\\"4824bc119a5fff6705f4d2b430bbea29\\"", "size": 356951, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-16T23:03:03.000Z", "contentLength": 356951, "httpStatusCode": 200}	59949712-27b7-4b71-b048-5bee5522ff65	\N	{}
2fbc9ccc-5a48-4077-aaf2-e22d39e3fe8c	products	planilhas/produtos_atualizados_20251217_185627.xlsx	\N	2025-12-17 21:56:27.782675+00	2025-12-17 21:56:27.782675+00	2025-12-17 21:56:27.782675+00	{"eTag": "\\"e47099810e3d5a80e85d983959325370\\"", "size": 16439, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:56:28.000Z", "contentLength": 16439, "httpStatusCode": 200}	07e1617d-3504-4828-964c-9ea598bcc2b9	\N	{}
321a830f-e936-46d5-aebf-2376d8df8d68	products	produtos/shared/drive_1CBfqo11pWdu9qIzT1fMV8Z3RCxeJeuIj.jpg	\N	2025-12-17 22:07:54.151298+00	2026-03-16 23:12:31.867288+00	2025-12-17 22:07:54.151298+00	{"eTag": "\\"af36e46944b0e83810ed61364bf3c06a\\"", "size": 87977, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:32.000Z", "contentLength": 87977, "httpStatusCode": 200}	47fa1b7a-5d54-4d1e-8ae5-a0aa832e7482	\N	{}
c92eb292-5351-444d-9b32-4e0cabcee90d	products	produtos/shared/drive_1KLW8-qOqy1HoX4yyRFz2X1h8gTW1Xggz.jpg	\N	2025-12-17 22:07:57.034292+00	2026-03-16 23:12:35.067927+00	2025-12-17 22:07:57.034292+00	{"eTag": "\\"b705d8cb6c79e6dab7396568fe9156cc\\"", "size": 476219, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:35.000Z", "contentLength": 476219, "httpStatusCode": 200}	c38fab92-998b-44cd-888c-44e17c2d4091	\N	{}
3a4b9d6e-b938-453b-9789-2a2902f0947f	products	produtos/shared/drive_1mk-i2Tu5jNhiyGE1_BGRCb7R_0gm7MBK.jpg	\N	2025-12-17 22:07:59.769639+00	2026-03-16 23:12:38.138051+00	2025-12-17 22:07:59.769639+00	{"eTag": "\\"c0486200f763efaa3f72d909fac8261f\\"", "size": 208868, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:39.000Z", "contentLength": 208868, "httpStatusCode": 200}	8ad1da0e-2875-473c-a26c-07631a3e27a9	\N	{}
d70dbe30-d906-4845-86f2-8af3a8d4a250	products	produtos/shared/drive_1qYjYOHEYKACltCfyxaavvXVPxHP5ujIS.jpg	\N	2025-12-17 22:08:21.088054+00	2026-03-16 23:12:59.049978+00	2025-12-17 22:08:21.088054+00	{"eTag": "\\"55914d62f5f492e80604aff67f4d698d\\"", "size": 366745, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:13:00.000Z", "contentLength": 366745, "httpStatusCode": 200}	355225db-9ae0-4587-8b5b-41b27e206216	\N	{}
3bef0824-4419-4546-82a0-2b8d4432b41c	products	produtos/shared/drive_1MH4BuGqZgxlAB_dTApmymHVykkimCUtF.jpg	\N	2025-12-17 22:08:23.795906+00	2026-03-16 23:13:01.118381+00	2025-12-17 22:08:23.795906+00	{"eTag": "\\"2b581d13b196968e79f29c07e7451c3d\\"", "size": 40665, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:13:02.000Z", "contentLength": 40665, "httpStatusCode": 200}	bc97bf8a-1fb7-41ff-8df7-2cf0108df1fd	\N	{}
2744336f-9513-4522-b55b-ccb371be969e	products	produtos/shared/drive_1E-8RW9gRBF0dsckNnMXAc0SgWWqxShDl.jpg	\N	2025-12-17 22:08:26.962465+00	2026-03-16 23:13:03.830311+00	2025-12-17 22:08:26.962465+00	{"eTag": "\\"9e2877a127f2b6e7e86c38f68ee8f05c\\"", "size": 32328, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:13:04.000Z", "contentLength": 32328, "httpStatusCode": 200}	3068631a-5052-4806-8967-864fde8bae93	\N	{}
f14e2abf-50f9-46c5-8c51-7233fcf667ed	products	produtos/shared/drive_14gd5LXGmEkGtkrtkP4CTZK7bx2khGrp3.jpg	\N	2025-12-17 21:59:40.306665+00	2025-12-17 21:59:40.306665+00	2025-12-17 21:59:40.306665+00	{"eTag": "\\"0554713f31dc4c66289aaf75314d557b\\"", "size": 221791, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:59:41.000Z", "contentLength": 221791, "httpStatusCode": 200}	8771e922-6527-4a55-a020-7b4fa9980440	\N	{}
122519a7-c3bf-458d-90b9-f9b76292e9fe	products	produtos/shared/drive_1h6BMe6xyL6KHyk12fwK4nxdnYkTjksDX.jpg	\N	2025-12-17 21:59:43.432721+00	2025-12-17 21:59:43.432721+00	2025-12-17 21:59:43.432721+00	{"eTag": "\\"686e931ae6df7fceffe1497e36de8827\\"", "size": 290776, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:59:44.000Z", "contentLength": 290776, "httpStatusCode": 200}	45e4a7bb-b6f5-4dc5-8d80-b8a4824fa325	\N	{}
be0efa1c-a490-47b1-ab13-6bfa440707e6	products	produtos/shared/drive_1DoUh-Uc4n_isD_VlJX-XPQvAzV2WogzU.jpg	\N	2025-12-17 21:59:47.963201+00	2025-12-17 21:59:47.963201+00	2025-12-17 21:59:47.963201+00	{"eTag": "\\"812a6c689456dc6d450adbcbeee79e2d\\"", "size": 323670, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:59:48.000Z", "contentLength": 323670, "httpStatusCode": 200}	8c9e82da-f766-4b09-a000-25ada72964c9	\N	{}
19e6d91b-8727-4a3f-8a6d-3907da9b6d1d	products	produtos/shared/drive_1YLYJjL1SzXLVYLJqhMT5vgVexYOUJb0S.jpg	\N	2025-12-17 21:59:53.464994+00	2025-12-17 21:59:53.464994+00	2025-12-17 21:59:53.464994+00	{"eTag": "\\"f057390aebc33379a6bf905bc91f822a\\"", "size": 345616, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:59:54.000Z", "contentLength": 345616, "httpStatusCode": 200}	c542d4e0-43c3-4c98-913f-a1bba1a1a829	\N	{}
004bf5ed-714e-47db-89ff-c5fb0bb5c882	products	produtos/shared/drive_1iXkzp4iMYunZHSMee-4d_tkwXr_5vy_r.jpg	\N	2025-12-17 22:08:02.964837+00	2026-03-16 23:12:41.310666+00	2025-12-17 22:08:02.964837+00	{"eTag": "\\"f5ed9311a564032aa1baebd7cc8fd71e\\"", "size": 632809, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:42.000Z", "contentLength": 632809, "httpStatusCode": 200}	3dd499fc-f76f-4c75-b3d2-a89526dc2103	\N	{}
3536083b-6ea6-4af7-9c8c-705fec3084b2	products	produtos/shared/drive_1pmNU3bFCavf2LS-QT-BdwymsKWKJyg_f.jpg	\N	2025-12-17 21:59:56.848782+00	2025-12-17 21:59:56.848782+00	2025-12-17 21:59:56.848782+00	{"eTag": "\\"db780cf47937a8ed0ed748118a4c589d\\"", "size": 202599, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T21:59:57.000Z", "contentLength": 202599, "httpStatusCode": 200}	9fff6c6d-ed5d-41b3-8469-cb300998f1fd	\N	{}
1289b6a4-226d-4e98-ae66-8f8557a36329	products	produtos/shared/drive_1AC8yKqsrMzo76f8mPWNO7JSbzJEV-MNg.jpg	\N	2025-12-17 22:08:06.045856+00	2026-03-16 23:12:44.07381+00	2025-12-17 22:08:06.045856+00	{"eTag": "\\"668ecad499641a4de7a5ec9ff6f2cced\\"", "size": 242373, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:44.000Z", "contentLength": 242373, "httpStatusCode": 200}	7cd6aa83-422e-49dd-8204-144fd8a58821	\N	{}
8d0ec2d5-5919-40b3-91ff-4fd589ace263	products	produtos/shared/drive_1e9KnVAXH6_ieOtFuRhxagIQFynfgiYDO.jpg	\N	2025-12-17 22:08:08.807042+00	2026-03-16 23:12:46.924468+00	2025-12-17 22:08:08.807042+00	{"eTag": "\\"ec965cf14fbd359d4180e1040883d804\\"", "size": 382070, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:47.000Z", "contentLength": 382070, "httpStatusCode": 200}	25d43d6e-51d6-4b90-bce0-7ff9f53b35eb	\N	{}
1b835871-7f7d-44e2-9737-e269d0cfa7e2	products	planilhas/produtos_atualizados_20251217_190021.xlsx	\N	2025-12-17 22:00:21.770056+00	2025-12-17 22:00:21.770056+00	2025-12-17 22:00:21.770056+00	{"eTag": "\\"81403cbafd4a50153c0a25077b35dec3\\"", "size": 9251, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2025-12-17T22:00:22.000Z", "contentLength": 9251, "httpStatusCode": 200}	d1bc1626-b86f-465a-8c8f-bb6def630acb	\N	{}
a6aad3ca-02b8-4615-b145-c9d28c640de9	products	produtos/shared/drive_1ZU1L9QklrufG9J1gm1INEHoRrcRLOQGx.jpg	\N	2025-12-17 22:05:27.967621+00	2025-12-17 22:05:27.967621+00	2025-12-17 22:05:27.967621+00	{"eTag": "\\"97533f050e9035eb867c1cc31a38bb34\\"", "size": 257706, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T22:05:28.000Z", "contentLength": 257706, "httpStatusCode": 200}	b5de7160-eed7-4d6b-bfe0-84365fc9e161	\N	{}
a8985c44-b257-4221-aeba-2058aceabc72	products	produtos/shared/drive_1gJQDz38MDgiDyYjml0xMkAT33oaVdLKI.jpg	\N	2025-12-17 22:05:34.225473+00	2025-12-17 22:05:34.225473+00	2025-12-17 22:05:34.225473+00	{"eTag": "\\"8791de4cfe4820b21b2b47b86748c4a8\\"", "size": 196052, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T22:05:35.000Z", "contentLength": 196052, "httpStatusCode": 200}	01b1c3b2-c336-4329-92ec-42efb71efe09	\N	{}
48d30cd8-0987-4da5-8061-9226e850128b	products	produtos/shared/drive_1ioMkYVymn7lP1Y98V2IyhIg77nOYDl7m.jpg	\N	2025-12-17 22:05:37.014466+00	2025-12-17 22:05:37.014466+00	2025-12-17 22:05:37.014466+00	{"eTag": "\\"1217cf255d7db27e2e47ee53890074ca\\"", "size": 297538, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T22:05:37.000Z", "contentLength": 297538, "httpStatusCode": 200}	e7e8f1d9-f09d-4894-a454-391b6e2de90d	\N	{}
8ab18674-f334-47b9-a343-63af1d482ca4	products	produtos/shared/drive_1O4z-VK-P0UQrz27E6APb6XIrXFCjFCd6.jpg	\N	2025-12-17 22:08:11.0945+00	2026-03-16 23:12:49.438896+00	2025-12-17 22:08:11.0945+00	{"eTag": "\\"3f1f930aa9117c3b2b81575fb194a932\\"", "size": 437435, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:50.000Z", "contentLength": 437435, "httpStatusCode": 200}	b6c17eee-b932-4a85-8f04-6f7ead6f52af	\N	{}
2af2d09a-1cce-4b6d-9e74-03ca38ea34c6	products	produtos/shared/drive_1d8pzHRsmIRWUSUnRC_sw8jQPTcyzjHd6.jpg	\N	2025-12-17 22:05:39.847891+00	2025-12-17 22:05:39.847891+00	2025-12-17 22:05:39.847891+00	{"eTag": "\\"880f246760a068da9a361230b04c7f3e\\"", "size": 460577, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T22:05:40.000Z", "contentLength": 460577, "httpStatusCode": 200}	b9220b09-c40e-4a73-be23-b2a0f4ce880c	\N	{}
33871a19-357a-46bf-8230-082f08d52432	products	produtos/shared/drive_1tBuiXUp0EWuQg-cJpwhAIWxmt9lsrIFM.jpg	\N	2025-12-17 22:05:42.665305+00	2025-12-17 22:05:42.665305+00	2025-12-17 22:05:42.665305+00	{"eTag": "\\"9b90c2a67a2bf7c060c1aaa704d4c133\\"", "size": 196830, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2025-12-17T22:05:43.000Z", "contentLength": 196830, "httpStatusCode": 200}	96ef8ec1-adbc-4f94-b1a5-65cf254bd56f	\N	{}
e0ca012a-8310-4756-8941-2afad7d7535e	products	produtos/shared/drive_18MnErn3GKQJ5SyOrj0DCWqhW-IHBYtIG.jpg	\N	2025-12-17 22:08:18.615641+00	2026-03-16 23:12:56.479701+00	2025-12-17 22:08:18.615641+00	{"eTag": "\\"89e62ed0facfca4af191855b7fb5deae\\"", "size": 319910, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:57.000Z", "contentLength": 319910, "httpStatusCode": 200}	03b38cb6-99ad-4fb7-afa0-92e8a388b25f	\N	{}
0a90e597-8ff5-4585-85f6-9d2b5c276ef1	products	planilhas/produtos_atualizados_20251217_190847.xlsx	\N	2025-12-17 22:08:48.077596+00	2025-12-17 22:08:48.077596+00	2025-12-17 22:08:48.077596+00	{"eTag": "\\"f8c5513a864b01065217120066376128\\"", "size": 15413, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2025-12-17T22:08:49.000Z", "contentLength": 15413, "httpStatusCode": 200}	2ce2e31d-bff3-4010-99ba-67564c85dad5	\N	{}
80aa0562-7035-4c52-83c3-6ea4ec1c677d	products	planilhas/produtos_atualizados_20260304_174444.xlsx	\N	2026-03-04 20:44:44.741276+00	2026-03-04 20:44:44.741276+00	2026-03-04 20:44:44.741276+00	{"eTag": "\\"c528592669b1725d3576397ccefec4ab\\"", "size": 47487, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-04T20:44:45.000Z", "contentLength": 47487, "httpStatusCode": 200}	b10a5b22-6197-4045-a90a-c2fbb4fa2a76	\N	{}
ce77d3d6-9047-4f1e-a6b7-c26bfaae8108	products	produtos/shared/drive_1Lvn4Wh-WKAJYkKnkHLYXFt01VhtHraSt.jpg	\N	2025-12-17 22:08:29.34659+00	2026-03-16 23:13:05.660251+00	2025-12-17 22:08:29.34659+00	{"eTag": "\\"8ef68c7e313a08e27a262cf9f8d72879\\"", "size": 36413, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:13:06.000Z", "contentLength": 36413, "httpStatusCode": 200}	de23c135-7253-46a1-b8fc-6ff3663e1f44	\N	{}
13a9d247-180a-422c-854b-e4246a250337	products	planilhas/produtos_atualizados_20260304_170723.xlsx	\N	2026-03-04 20:07:23.869671+00	2026-03-04 20:07:23.869671+00	2026-03-04 20:07:23.869671+00	{"eTag": "\\"9a933d23f0fd3024bb712885d5e431ec\\"", "size": 47487, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-04T20:07:24.000Z", "contentLength": 47487, "httpStatusCode": 200}	451a832d-f19a-4de1-bf02-a9197b94a3ad	\N	{}
e8e022ff-2266-4f95-9626-db309218508a	products	planilhas/produtos_atualizados_20260309_111105.xlsx	\N	2026-03-09 14:11:06.820829+00	2026-03-09 14:11:06.820829+00	2026-03-09 14:11:06.820829+00	{"eTag": "\\"39dc69fbe13afb1af64662034c651d58\\"", "size": 47487, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-09T14:11:07.000Z", "contentLength": 47487, "httpStatusCode": 200}	a793223c-1268-4aad-a47f-745012dbfb5d	\N	{}
9532e98f-eb57-477d-9141-afd2f70e9079	products	planilhas/produtos_atualizados_20260316_192040.xlsx	\N	2026-03-16 22:20:41.592268+00	2026-03-16 22:20:41.592268+00	2026-03-16 22:20:41.592268+00	{"eTag": "\\"b2ddf6565876aeb040f6162c615342cb\\"", "size": 13380, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-16T22:20:42.000Z", "contentLength": 13380, "httpStatusCode": 200}	820f4fb2-0186-4c54-963b-321a00829f92	\N	{}
5f05d167-3c8d-4a46-a55c-25c87f37fc0e	products	planilhas/produtos_atualizados_20260316_193121.xlsx	\N	2026-03-16 22:31:22.438256+00	2026-03-16 22:31:22.438256+00	2026-03-16 22:31:22.438256+00	{"eTag": "\\"3f64fc8589a599a7d26186f762da8a33\\"", "size": 10023, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-16T22:31:23.000Z", "contentLength": 10023, "httpStatusCode": 200}	f5176b91-28e5-4ae1-85d0-3ad78c076e1a	\N	{}
b303c9ab-5828-4612-ab9b-50b5fa4634d3	products	planilhas/produtos_atualizados_20260316_193927.xlsx	\N	2026-03-16 22:39:28.599007+00	2026-03-16 22:39:28.599007+00	2026-03-16 22:39:28.599007+00	{"eTag": "\\"4943a530c67ff5fade13ddb64807e5a6\\"", "size": 6645, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-16T22:39:29.000Z", "contentLength": 6645, "httpStatusCode": 200}	1418c1c3-133f-40d7-b4eb-7a3dcf91c41c	\N	{}
c12549e8-8eef-4394-b598-56224aa3bcb2	products	planilhas/produtos_atualizados_20260316_194929.xlsx	\N	2026-03-16 22:49:29.617715+00	2026-03-16 22:49:29.617715+00	2026-03-16 22:49:29.617715+00	{"eTag": "\\"f99c54bbd7c5a7b6a694139b8b6104af\\"", "size": 8704, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-16T22:49:30.000Z", "contentLength": 8704, "httpStatusCode": 200}	d6201f22-787a-4c36-b070-f97d330771b8	\N	{}
19bdc752-217f-43fd-b847-6416fe06f730	products	planilhas/produtos_atualizados_20260316_201322.xlsx	\N	2026-03-16 23:13:22.569903+00	2026-03-16 23:13:22.569903+00	2026-03-16 23:13:22.569903+00	{"eTag": "\\"f5caf7ba2712a7e56ad60506829e4938\\"", "size": 15450, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:13:23.000Z", "contentLength": 15450, "httpStatusCode": 200}	4555487d-3005-4d27-9f25-004669434fda	\N	{}
756cecb4-fd6c-4d6f-953e-f9d247957097	products	planilhas/produtos_atualizados_20260316_195625.xlsx	\N	2026-03-16 22:56:25.969086+00	2026-03-16 22:56:25.969086+00	2026-03-16 22:56:25.969086+00	{"eTag": "\\"5646711ea61c77bf38b89cf2dc479d4f\\"", "size": 16535, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-16T22:56:26.000Z", "contentLength": 16535, "httpStatusCode": 200}	8e922ecb-de60-44f5-9ff1-19ebba663626	\N	{}
2f089933-d76c-42b0-ac8c-dd5f39f1444a	products	produtos/shared/drive_1vWeuIQ3xnKFBk-2aVSYWu-e6cdHujtBN.jpg	\N	2025-12-17 21:59:15.326762+00	2026-03-16 23:02:00.653342+00	2025-12-17 21:59:15.326762+00	{"eTag": "\\"0a0a0389be203fc0fe56eaea1519cd82\\"", "size": 123515, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:01.000Z", "contentLength": 123515, "httpStatusCode": 200}	c43ffdd6-263d-40f3-acb2-5cc95da087e6	\N	{}
52c64058-7dde-458e-b839-c7d0c846871c	products	produtos/shared/drive_1uEoJDbVrtXsmvWADdkAErxdaB5YiS9kR.jpg	\N	2025-12-17 21:59:17.750132+00	2026-03-16 23:02:03.084891+00	2025-12-17 21:59:17.750132+00	{"eTag": "\\"41c74c4a8a711c34e4f3007c28adba5d\\"", "size": 167597, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:04.000Z", "contentLength": 167597, "httpStatusCode": 200}	23d3f4b1-e536-4c31-8714-51da470eae03	\N	{}
824b14b2-f859-45bf-92a9-c4efca4c7b7c	products	produtos/shared/drive_1mGkfT_9WK-jAZ1hPPWJ9emLPS66xQDe7.jpg	\N	2025-12-17 21:59:20.957863+00	2026-03-16 23:02:06.361721+00	2025-12-17 21:59:20.957863+00	{"eTag": "\\"c0f04032c418af4a96287bdd9ee4872e\\"", "size": 194496, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:07.000Z", "contentLength": 194496, "httpStatusCode": 200}	734f84a9-547c-443a-9495-9e48c85d9e06	\N	{}
a51e57ee-1ae6-4657-987a-783cdc918e62	products	produtos/shared/drive_15Xc-pIVByVb3AU3N8jAOKJyPKBfYc56B.jpg	\N	2025-12-17 21:59:24.383165+00	2026-03-16 23:02:09.130938+00	2025-12-17 21:59:24.383165+00	{"eTag": "\\"6778aa455893b60dd84b6d6f29c89179\\"", "size": 94320, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:10.000Z", "contentLength": 94320, "httpStatusCode": 200}	43a91826-fbc9-4557-9def-f86a85066b5b	\N	{}
ebe59728-5375-412c-b008-5028e6194be8	products	produtos/shared/drive_10rVEdsmk2BsX6-OWMoSWqJNNrf6I6UVE.jpg	\N	2025-12-17 21:59:27.740037+00	2026-03-16 23:02:11.748193+00	2025-12-17 21:59:27.740037+00	{"eTag": "\\"1232385923f015436ed58c6373ab709c\\"", "size": 157244, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:12.000Z", "contentLength": 157244, "httpStatusCode": 200}	33b735c3-9568-45a6-909a-535bfd1b093c	\N	{}
7e989b7f-8579-4c46-9d94-f6a704fdaa37	products	produtos/shared/drive_1jpuBrVes5JNmmIeZX_d_c8mjn2qyuBry.jpg	\N	2025-12-17 21:59:30.737297+00	2026-03-16 23:02:14.724082+00	2025-12-17 21:59:30.737297+00	{"eTag": "\\"c0483f325b368f20cc26491f8ea7cfe0\\"", "size": 171883, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:15.000Z", "contentLength": 171883, "httpStatusCode": 200}	c4ebfec7-a0b8-4c03-8250-01ddf77f061a	\N	{}
2b533e9c-9206-45c6-87f5-9a135c1dbb79	products	produtos/shared/drive_1_dEk9kt3j15bjmqfjTm4fh4Ah-S77J-8.jpg	\N	2025-12-17 21:59:32.845762+00	2026-03-16 23:02:17.20219+00	2025-12-17 21:59:32.845762+00	{"eTag": "\\"8900d36ff96c220ae2631da79e42c26c\\"", "size": 154968, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:18.000Z", "contentLength": 154968, "httpStatusCode": 200}	1105aa53-29f0-49c1-9e65-d5a3fcaddee0	\N	{}
b997b210-2b76-494f-a179-fb5aff3d8c89	products	produtos/shared/drive_1TQGoIuNyLax8SiVSxYNRDJZNXEv3nCd_.jpg	\N	2025-12-17 21:59:34.722586+00	2026-03-16 23:02:19.295041+00	2025-12-17 21:59:34.722586+00	{"eTag": "\\"0e550be068a22e466a287a87df6b0fa7\\"", "size": 164698, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:20.000Z", "contentLength": 164698, "httpStatusCode": 200}	050bf44d-67dc-42c5-8674-190b5f1823bb	\N	{}
169dbbf6-0ce0-424c-b684-033f8fa8723d	products	produtos/shared/drive_1Maf-aXMHUJ8tEkLleZWz1VF6DeIfeuz3.jpg	\N	2025-12-17 21:59:37.824819+00	2026-03-16 23:02:22.838178+00	2025-12-17 21:59:37.824819+00	{"eTag": "\\"43e373400d849ca4a26f669204335335\\"", "size": 133646, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:23.000Z", "contentLength": 133646, "httpStatusCode": 200}	45b9b965-dc6f-4ce5-b9eb-95dcec54c0ee	\N	{}
f27dcc46-bb79-4e23-bf16-63d68d8ad59f	products	produtos/shared/drive_1x55H6CsJaXaW6xKKLidjZROyx7S9WRrv.jpg	\N	2025-12-17 22:00:00.21659+00	2026-03-16 23:02:30.835956+00	2025-12-17 22:00:00.21659+00	{"eTag": "\\"060a164c0927d88511bee8c649fec4db\\"", "size": 167501, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:31.000Z", "contentLength": 167501, "httpStatusCode": 200}	2b800d12-80d3-4dfd-bf05-769f9177ae6f	\N	{}
59100639-949e-4a16-9417-e11a82ae370e	products	produtos/shared/drive_1gNHLCUqEc6EKqxdmIb8YNJVzCTE1nyXy.jpg	\N	2025-12-17 22:00:04.875866+00	2026-03-16 23:02:35.712314+00	2025-12-17 22:00:04.875866+00	{"eTag": "\\"64e80abadf60e804db8dcb4470c3f9f7\\"", "size": 184916, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:36.000Z", "contentLength": 184916, "httpStatusCode": 200}	8e7052d5-e22a-495c-b39c-8b699705032e	\N	{}
ce95d5ef-1960-4e4f-a8a1-248428bcd41b	products	produtos/shared/drive_1VZuzVOCfDm8j9OoaRfBXDFUcwBSxA5CL.jpg	\N	2025-12-17 22:00:07.390329+00	2026-03-16 23:02:38.753014+00	2025-12-17 22:00:07.390329+00	{"eTag": "\\"6c6d3f7cb0af4a61eed4426652783920\\"", "size": 203570, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:39.000Z", "contentLength": 203570, "httpStatusCode": 200}	6782e2c0-cf02-4a4f-ad6b-9a0e3a4bee12	\N	{}
9aff3226-4fdb-4895-8111-ecdc459be7bf	products	produtos/shared/drive_1yMP1eQ_zg6ldv_32NLNoeZiKyaShe_NZ.jpg	\N	2025-12-17 22:00:10.872569+00	2026-03-16 23:02:43.341474+00	2025-12-17 22:00:10.872569+00	{"eTag": "\\"5d85f71c01667c28ce2237dddb142cf8\\"", "size": 61857, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:44.000Z", "contentLength": 61857, "httpStatusCode": 200}	ef00f6d9-a654-4805-8522-f772d70b05aa	\N	{}
0cf36b74-11ba-4975-9cc2-3e9385a0158e	products	produtos/shared/drive_1B_XoQtjrtkiOZxtbM0WPSPQeyIB4glvq.jpg	\N	2025-12-17 22:00:13.228023+00	2026-03-16 23:02:45.727253+00	2025-12-17 22:00:13.228023+00	{"eTag": "\\"ce967353589788561581277ed9116510\\"", "size": 61857, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:46.000Z", "contentLength": 61857, "httpStatusCode": 200}	0f641dcb-3da0-4875-b79a-2729df6570aa	\N	{}
83d8014b-b64a-4044-a815-d60ff678ecc7	products	planilhas/produtos_atualizados_20260316_200253.xlsx	\N	2026-03-16 23:02:53.604279+00	2026-03-16 23:02:53.604279+00	2026-03-16 23:02:53.604279+00	{"eTag": "\\"669e04874bb87bcb11563765528e4a71\\"", "size": 9268, "mimetype": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:02:54.000Z", "contentLength": 9268, "httpStatusCode": 200}	6560ef81-02e4-4b6a-a1f9-58ddd97e5ad3	\N	{}
0f7dc465-12f0-4f91-8345-40b670995ffa	products	produtos/shared/drive_1r31kw3bjyJhY-Bb_yGDFLgr2x7fX_yvf.jpg	\N	2025-12-17 22:05:45.127417+00	2026-03-16 23:10:16.105248+00	2025-12-17 22:05:45.127417+00	{"eTag": "\\"340e04bf1797eb4ead41c8f1b8a62195\\"", "size": 303250, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:17.000Z", "contentLength": 303250, "httpStatusCode": 200}	1756ef0a-e07a-46b2-8f28-642c21dbb7e9	\N	{}
7371d314-1f6c-4c10-b6c5-62057043cf36	products	produtos/shared/drive_1xsgdk8esAjvcj-M09LKP9x21qgkMp9c4.jpg	\N	2025-12-17 22:05:47.461489+00	2026-03-16 23:10:18.198214+00	2025-12-17 22:05:47.461489+00	{"eTag": "\\"0343c0f55dab5b70b2e13281f43704a4\\"", "size": 318520, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:19.000Z", "contentLength": 318520, "httpStatusCode": 200}	f9331bbb-52db-4f68-b790-121b3e4a4a44	\N	{}
e2319bbd-3fee-483d-867b-ee831055c52b	products	produtos/shared/drive_1jqCScMS0XsuxvXWyhaRriV_KosrVetEY.jpg	\N	2025-12-17 22:05:50.287009+00	2026-03-16 23:10:21.001976+00	2025-12-17 22:05:50.287009+00	{"eTag": "\\"683792f31dcd65dd1f12e11d5ef5fce3\\"", "size": 225098, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:21.000Z", "contentLength": 225098, "httpStatusCode": 200}	22c399d0-a8b2-4881-8a4c-038ca198c91f	\N	{}
373c409e-400b-48ce-b480-3e94b4d62ec4	products	produtos/shared/drive_1FsjrgRN4L8oZgDArqpaBueU3ZrZEU3Wd.jpg	\N	2025-12-17 22:05:53.24454+00	2026-03-16 23:10:23.292339+00	2025-12-17 22:05:53.24454+00	{"eTag": "\\"dea35e992e126c2bfca7f4fdab585e98\\"", "size": 269916, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:24.000Z", "contentLength": 269916, "httpStatusCode": 200}	11e0a64d-8b60-4113-a0d8-403b60936c6d	\N	{}
d3127759-8bed-405a-a3c1-47d7d6030c47	products	produtos/shared/drive_1Pc17SOUNTPLfhAa_D4EvviG1OQ9dGJWU.jpg	\N	2025-12-17 22:05:55.776188+00	2026-03-16 23:10:25.611614+00	2025-12-17 22:05:55.776188+00	{"eTag": "\\"4a2acc92ddee73d720c6a817a3ff7e84\\"", "size": 226084, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:26.000Z", "contentLength": 226084, "httpStatusCode": 200}	b2fd5def-29e3-41e4-8308-09216a5d152a	\N	{}
d34b1bb8-db40-4e9b-931a-cb8951e103ad	products	produtos/shared/drive_1UvNfcXkWmYK9-EqwDcSSyaSs9uXwWiMZ.jpg	\N	2025-12-17 22:05:57.89694+00	2026-03-16 23:10:28.215836+00	2025-12-17 22:05:57.89694+00	{"eTag": "\\"ee475124ca685bccbf3bb33dfd903c6e\\"", "size": 364901, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:29.000Z", "contentLength": 364901, "httpStatusCode": 200}	554f2652-7901-44bf-8185-550803d9677a	\N	{}
d1047d09-b59d-4917-bbbe-90f5b39ec28c	products	produtos/shared/drive_1AjGhbhZFOlfcjG-_M5wvgLVLJbbRzd1M.jpg	\N	2025-12-17 22:06:00.649951+00	2026-03-16 23:10:30.940909+00	2025-12-17 22:06:00.649951+00	{"eTag": "\\"e6e6e54ab52ac152aaab4a6f0ede4ce6\\"", "size": 168901, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:31.000Z", "contentLength": 168901, "httpStatusCode": 200}	d1fad3be-8fde-43cc-9fb0-db31db699a74	\N	{}
9fee6ce7-cfaf-44b0-959f-4ca65f436d64	products	produtos/shared/drive_1bQlsyfhcdValBdbvIV8sM2bMtTNltPY1.jpg	\N	2025-12-17 22:06:04.023393+00	2026-03-16 23:10:35.008762+00	2025-12-17 22:06:04.023393+00	{"eTag": "\\"14a8f4c476c530cd5da68b3d598e6e40\\"", "size": 188284, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:35.000Z", "contentLength": 188284, "httpStatusCode": 200}	f6770ff6-c102-4bc2-897b-f336210f0186	\N	{}
3e6af543-8920-44d3-bb22-40df7ee029ba	products	produtos/shared/drive_1FBfaSCBnTjZggBZIwXrSG_C8v0Av8vJh.jpg	\N	2025-12-17 22:06:06.462112+00	2026-03-16 23:10:37.584989+00	2025-12-17 22:06:06.462112+00	{"eTag": "\\"c47181cca86e3093de6d8c721a775cdd\\"", "size": 162274, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:38.000Z", "contentLength": 162274, "httpStatusCode": 200}	6fe307d7-8d08-470d-855a-7585fdb39b92	\N	{}
e4c1b66f-55f5-4ff4-b502-cf9a7cc84bfc	products	produtos/shared/drive_1TJvrCGuorT6hP_6CN5aqV_jH4Hkht75m.jpg	\N	2025-12-17 22:06:08.957076+00	2026-03-16 23:10:40.001511+00	2025-12-17 22:06:08.957076+00	{"eTag": "\\"81963bc7eaff69d69e94166817d23835\\"", "size": 247405, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:40.000Z", "contentLength": 247405, "httpStatusCode": 200}	9dc121bd-53d6-4cc0-82fd-4d07caac790a	\N	{}
7e806442-f3e9-4415-aa3c-be31778581f1	products	produtos/shared/drive_1Zn_wZTsWDP1g8qYp081_8J1OSiTRnQ0y.jpg	\N	2025-12-17 22:06:12.993711+00	2026-03-16 23:10:43.713473+00	2025-12-17 22:06:12.993711+00	{"eTag": "\\"1b265ea90af17aa0e9754aaa5a695f14\\"", "size": 193177, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:44.000Z", "contentLength": 193177, "httpStatusCode": 200}	879e8453-1889-49ce-9ade-93b46278c62d	\N	{}
cdfa3e2c-ad69-4b91-9779-15960d053266	products	produtos/shared/drive_1gO7TaBdiJjJ7O6e7T9dOTlfdiKekXyKz.jpg	\N	2025-12-17 22:06:14.940065+00	2026-03-16 23:10:45.7711+00	2025-12-17 22:06:14.940065+00	{"eTag": "\\"43a0bf988a1a5bf72a9d546db712cf91\\"", "size": 156674, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:46.000Z", "contentLength": 156674, "httpStatusCode": 200}	c74a72d8-46ad-4448-bb5c-ee73f6d9a2ac	\N	{}
44424e2d-f610-4763-828d-8f9a06ba8336	products	produtos/shared/drive_1ov1rZRW3xWPAeIP8Gvm3VXj9TjJmJg2T.jpg	\N	2025-12-17 22:06:17.246454+00	2026-03-16 23:10:47.983473+00	2025-12-17 22:06:17.246454+00	{"eTag": "\\"6d7d0b6d8f214a04231d447370749c01\\"", "size": 264123, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:48.000Z", "contentLength": 264123, "httpStatusCode": 200}	64110ce1-e7c9-42e8-b60d-fba8fcb6103c	\N	{}
943b8bfa-f415-4174-8204-9ab868174c3e	products	produtos/shared/drive_1_okISuE0FUjtYPVpJo4ZXYDje7QOAC9_.jpg	\N	2025-12-17 22:06:20.524446+00	2026-03-16 23:10:51.807176+00	2025-12-17 22:06:20.524446+00	{"eTag": "\\"4d05cf59524c86802e310fa05ed3915a\\"", "size": 209123, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:52.000Z", "contentLength": 209123, "httpStatusCode": 200}	0e0de1f3-ef88-44d0-ab36-4420c24b22a3	\N	{}
fb14408c-bca0-4e54-9807-4f741f11c797	products	produtos/shared/drive_1dpGZtwkfp__Z0bGVaV0N7KMkz4KIsV2e.jpg	\N	2025-12-17 22:06:25.425144+00	2026-03-16 23:10:56.37467+00	2025-12-17 22:06:25.425144+00	{"eTag": "\\"519bed9fc2b21637848363fae981d1b0\\"", "size": 241604, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:57.000Z", "contentLength": 241604, "httpStatusCode": 200}	c7760d57-a246-4486-8b8f-023fdf48f136	\N	{}
133dc73a-93e7-4ca3-b0ca-d7f941879a8e	products	produtos/shared/drive_1cnNODuYVO1vAaqGc_IExKbYloptILnV7.jpg	\N	2025-12-17 22:06:27.239766+00	2026-03-16 23:10:59.032911+00	2025-12-17 22:06:27.239766+00	{"eTag": "\\"4d0e79d21794473e51b3e06bcf047d88\\"", "size": 192795, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:10:59.000Z", "contentLength": 192795, "httpStatusCode": 200}	55e14752-789b-42f4-bf89-6678182454c0	\N	{}
199fd561-0d89-4726-a796-d7859d45b038	products	produtos/shared/drive_1DsdU1EnXq05904x7_4oJuCzAj9w_Y8G9.jpg	\N	2025-12-17 22:06:29.280548+00	2026-03-16 23:11:01.477692+00	2025-12-17 22:06:29.280548+00	{"eTag": "\\"28696b7370dd3d6a8f0096091bcfcd09\\"", "size": 175869, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:02.000Z", "contentLength": 175869, "httpStatusCode": 200}	58a439ed-2fc8-499c-a921-23903b502baf	\N	{}
24fec22a-07a7-4e85-ae41-4193d1dc9cfb	products	produtos/shared/drive_1lAtFSjGG1NwsShNT6cm88g7tIYL5Q4TS.jpg	\N	2025-12-17 22:06:33.07406+00	2026-03-16 23:11:05.566902+00	2025-12-17 22:06:33.07406+00	{"eTag": "\\"3018953183288ac87638882be8d27ad0\\"", "size": 458585, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:06.000Z", "contentLength": 458585, "httpStatusCode": 200}	003ea981-4701-4e54-a186-80db0954df02	\N	{}
2b0d3ce4-bcdc-4a59-8ee2-6da8f80eb2ea	products	produtos/shared/drive_173qilAnR3kDToDnmljhUtZMCaitvTYQH.jpg	\N	2025-12-17 22:06:36.779182+00	2026-03-16 23:11:09.764761+00	2025-12-17 22:06:36.779182+00	{"eTag": "\\"c33585a35f7b5155ddd0ea2fe3dfdd5d\\"", "size": 203143, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:10.000Z", "contentLength": 203143, "httpStatusCode": 200}	ea971b2d-55c2-4aec-9e05-94600184823c	\N	{}
bf28cda5-479c-4ca2-986f-6ad4d0b34148	products	produtos/shared/drive_1gBUxYkZwd2uD-SsyFgNpQqw_W4FCYei-.jpg	\N	2025-12-17 22:06:40.277459+00	2026-03-16 23:11:13.247799+00	2025-12-17 22:06:40.277459+00	{"eTag": "\\"74ed3550b8cf19472ef0f22d9ba9d5fc\\"", "size": 417150, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:14.000Z", "contentLength": 417150, "httpStatusCode": 200}	816086d6-e755-4278-83d4-1c738cec76d6	\N	{}
883e9d01-b4b9-453d-a7aa-cdf42e4e432c	products	produtos/shared/drive_1-0vmM9CT0WP1OibmTVflDNqq7sc9-0nS.jpg	\N	2025-12-17 22:06:42.920125+00	2026-03-16 23:11:16.903263+00	2025-12-17 22:06:42.920125+00	{"eTag": "\\"d7060ddad6374866c69d5bd2dbb6d50f\\"", "size": 283253, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:17.000Z", "contentLength": 283253, "httpStatusCode": 200}	5ea35ade-6e26-4dcc-b22d-032eca3b8d6f	\N	{}
2862a4c9-e878-46af-9f27-6798ef7fad12	products	produtos/shared/drive_1gXaGqfrD-KKLzKJsTHrVgO5NKyJToE14.jpg	\N	2025-12-17 22:06:45.84529+00	2026-03-16 23:11:20.42641+00	2025-12-17 22:06:45.84529+00	{"eTag": "\\"fd6e0f171ca5261d2360b6286b811885\\"", "size": 442042, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:21.000Z", "contentLength": 442042, "httpStatusCode": 200}	484e7d37-67f5-4c35-90cc-225141db315c	\N	{}
2f9fb0d3-c645-4bc3-ae3d-538a5e6e96ea	products	produtos/shared/drive_1akd34Rr_VYpc0p0gYBrzKrntEano-awD.jpg	\N	2025-12-17 22:06:48.768996+00	2026-03-16 23:11:23.723574+00	2025-12-17 22:06:48.768996+00	{"eTag": "\\"fcfc5092b1c4c976e53fa4215a187142\\"", "size": 310905, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:24.000Z", "contentLength": 310905, "httpStatusCode": 200}	b5a92114-0d80-428b-92ec-35f17bfccf42	\N	{}
088cd985-40fa-44d4-8b69-30a65b982996	products	produtos/shared/drive_1y3FKizxm95Yagkpwo5a9gwOcZwQ_vuoD.jpg	\N	2025-12-17 22:06:51.93004+00	2026-03-16 23:11:26.736332+00	2025-12-17 22:06:51.93004+00	{"eTag": "\\"b6087b3ed2ec1864c9f220070e3bd8d8\\"", "size": 522678, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:27.000Z", "contentLength": 522678, "httpStatusCode": 200}	bb0194e5-0819-4416-b47a-539d9be8cb8a	\N	{}
7deab201-c5c5-4243-b5c2-a7c069787f7a	products	produtos/shared/drive_1oMdp98I5L2qfklCrzaIWdTnWh0GfOroA.jpg	\N	2025-12-17 22:06:54.675438+00	2026-03-16 23:11:30.244174+00	2025-12-17 22:06:54.675438+00	{"eTag": "\\"3d0fadec36affff655664f50b18d0d79\\"", "size": 179544, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:31.000Z", "contentLength": 179544, "httpStatusCode": 200}	8f4be88e-0117-47e9-a0a9-3ce7b0da25d3	\N	{}
c529695d-0513-4686-8b9b-294d86810f5a	products	produtos/shared/drive_16VHgnibEuRB3Hgc0xPrI2nAt6HWdUi3R.jpg	\N	2025-12-17 22:06:57.420021+00	2026-03-16 23:11:32.964643+00	2025-12-17 22:06:57.420021+00	{"eTag": "\\"948800d2d1fa06b6704d40eaa5fe1415\\"", "size": 113594, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:33.000Z", "contentLength": 113594, "httpStatusCode": 200}	f0c925ca-6079-4c2d-a67b-a3b065469918	\N	{}
cf8b5652-e1d4-4afd-859b-dca93eb67c56	products	produtos/shared/drive_15DIhGDkjnyzBtg9wL3lDlRlVqThTRLcL.jpg	\N	2025-12-17 22:07:00.125852+00	2026-03-16 23:11:36.01112+00	2025-12-17 22:07:00.125852+00	{"eTag": "\\"7294f5f3666120918adc39096d2696cf\\"", "size": 225936, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:36.000Z", "contentLength": 225936, "httpStatusCode": 200}	eb9cf740-9865-4394-8100-02b5a5934962	\N	{}
1723a0d0-2403-4593-9d63-2578de60c213	products	produtos/shared/drive_1DppjPtQzJqq2rRr--z6RIZPFyfe8mhMS.jpg	\N	2025-12-17 22:07:02.988913+00	2026-03-16 23:11:38.980589+00	2025-12-17 22:07:02.988913+00	{"eTag": "\\"7d74894911de9af1ee9ffd23054c16d7\\"", "size": 201005, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:39.000Z", "contentLength": 201005, "httpStatusCode": 200}	c1c1780b-91df-4f49-a8cc-e89c6b968844	\N	{}
c1b782e3-6c49-4e29-88e7-f5037d5d7260	products	produtos/shared/drive_1uiIHsX-nwaZoypcFFStZ5i81UccY1gIF.jpg	\N	2025-12-17 22:07:05.385247+00	2026-03-16 23:11:41.407815+00	2025-12-17 22:07:05.385247+00	{"eTag": "\\"5ed9ca9a8c7016ee0b2db7229bde5c13\\"", "size": 103494, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:42.000Z", "contentLength": 103494, "httpStatusCode": 200}	58836a3b-5997-4383-88e8-ce2ec7cd84fd	\N	{}
5f1e2687-6585-4be7-aa29-56b17f4f7aa6	products	produtos/shared/drive_1m6kcrOMo_Xd7vhNyueFNCJpbnDyKFHOh.jpg	\N	2025-12-17 22:07:07.472119+00	2026-03-16 23:11:43.764601+00	2025-12-17 22:07:07.472119+00	{"eTag": "\\"ffe1c5b9b662b80b2836ca277fbeb444\\"", "size": 134455, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:44.000Z", "contentLength": 134455, "httpStatusCode": 200}	9d1ecb96-358c-4d6c-81c8-e4f641f6ef58	\N	{}
abe2df1c-0161-421a-bb8a-c805fce92b9b	products	produtos/shared/drive_1cQw4fEU-lwa4YWT5RUi3UBKupsALaGha.jpg	\N	2025-12-17 22:07:09.959224+00	2026-03-16 23:11:46.56962+00	2025-12-17 22:07:09.959224+00	{"eTag": "\\"083a4cd5618b40191a392838cb7484ee\\"", "size": 110088, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:47.000Z", "contentLength": 110088, "httpStatusCode": 200}	b8f9da37-56b0-401c-b76f-f0a4db09155c	\N	{}
2c5e3344-7851-45c9-ba66-40183ce19f53	products	produtos/shared/drive_1YL6eIoFkzAGDWbP1apzMuiIdKM72AWwr.jpg	\N	2025-12-17 22:07:12.653443+00	2026-03-16 23:11:48.94852+00	2025-12-17 22:07:12.653443+00	{"eTag": "\\"de01866839e62a4d1e73ccbdaed7e0ec\\"", "size": 22087, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:49.000Z", "contentLength": 22087, "httpStatusCode": 200}	7aaca42c-9e32-45e6-8b95-aa5e2e2ccbe1	\N	{}
6af5e903-73eb-4f6f-8ff7-849c4bd29790	products	produtos/shared/drive_1uCmd5KtUPGysECxIBeEFK3EdjEkFlIWx.jpg	\N	2025-12-17 22:07:15.593845+00	2026-03-16 23:11:51.584125+00	2025-12-17 22:07:15.593845+00	{"eTag": "\\"770ba3d2eda1add43f06e4f7db57f83a\\"", "size": 21357, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:52.000Z", "contentLength": 21357, "httpStatusCode": 200}	f7e32b1b-5235-4b7a-b8b3-f4520e7aec74	\N	{}
fca31491-2e36-428c-8f38-43a2624efd99	products	produtos/shared/drive_10iO4PjG0PaeRrNSla6zPLKo2Q_ova7Ac.jpg	\N	2025-12-17 22:07:17.455397+00	2026-03-16 23:11:53.401863+00	2025-12-17 22:07:17.455397+00	{"eTag": "\\"11531f82355ea86ee542333bbbe01d74\\"", "size": 24318, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:54.000Z", "contentLength": 24318, "httpStatusCode": 200}	955fdb02-392e-4d1f-9bc1-3d7bf5d751d9	\N	{}
05e30c78-d30e-4c38-8058-f46a8ab12893	products	produtos/shared/drive_1xBTZ7Wx81El4MZ7akFqCYU_1eON46Zgb.jpg	\N	2025-12-17 22:07:19.917587+00	2026-03-16 23:11:56.164457+00	2025-12-17 22:07:19.917587+00	{"eTag": "\\"49394a1ad0de7f5779fe37778c2dfd7e\\"", "size": 22688, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:11:57.000Z", "contentLength": 22688, "httpStatusCode": 200}	0e42e1dc-381d-4f38-a37d-b4390114d4d3	\N	{}
6abd23ea-8b8d-4cef-bd2f-66ea4834fc2d	products	produtos/shared/drive_1cZmTmNAoVwwL3V7Z4mzPsfKVh5u4KseN.jpg	\N	2025-12-17 22:07:23.493125+00	2026-03-16 23:11:59.628919+00	2025-12-17 22:07:23.493125+00	{"eTag": "\\"b9d0393e8010e69ff3a4521659939130\\"", "size": 169038, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:00.000Z", "contentLength": 169038, "httpStatusCode": 200}	4761de1b-13db-47ed-9c21-4ac289c67523	\N	{}
d82a80a7-46d9-41aa-9880-47336fbde429	products	produtos/shared/drive_1PmBByjvomJ9wUiZ28NSA51ez9IVA4-MO.jpg	\N	2025-12-17 22:07:27.689928+00	2026-03-16 23:12:03.591861+00	2025-12-17 22:07:27.689928+00	{"eTag": "\\"94899f9553590a386e904371fdec56ed\\"", "size": 162050, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:04.000Z", "contentLength": 162050, "httpStatusCode": 200}	018fef1a-f883-46fe-bb20-f0421b7ef742	\N	{}
d246c475-bea1-4e6e-8350-5a82c89dd9c3	products	produtos/shared/drive_1yIGthCvKfaH9THdaZc1mtlBv7eZ72dkZ.jpg	\N	2025-12-17 22:07:32.326007+00	2026-03-16 23:12:08.792084+00	2025-12-17 22:07:32.326007+00	{"eTag": "\\"68a7c965118a13dee7f83278f8b6fe78\\"", "size": 172847, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:09.000Z", "contentLength": 172847, "httpStatusCode": 200}	f00dbde5-818c-4c77-94e3-2ba9069940b4	\N	{}
f3ee81be-9108-430f-a032-7c70a0c619ba	products	produtos/shared/drive_1i0VHge2DjBDMhav7CKHa6yk1iPadVvoD.jpg	\N	2025-12-17 22:07:35.711999+00	2026-03-16 23:12:12.736093+00	2025-12-17 22:07:35.711999+00	{"eTag": "\\"8b89da462246fac6e3594997b9f78a8c\\"", "size": 159224, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:13.000Z", "contentLength": 159224, "httpStatusCode": 200}	aafd5a0c-eab7-44b2-b05c-bbcb08c37c17	\N	{}
a3be6424-397e-4d55-9e54-480cf5f08b90	products	produtos/shared/drive_14giHf5PURDW_AmOXPoHHDNP7d9CcvfWQ.jpg	\N	2025-12-17 22:07:44.253427+00	2026-03-16 23:12:20.85832+00	2025-12-17 22:07:44.253427+00	{"eTag": "\\"3d8f02300a8c330a247201f1934bf612\\"", "size": 419638, "mimetype": "image/png", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:21.000Z", "contentLength": 419638, "httpStatusCode": 200}	9e4eb8eb-8011-443f-81bf-19e68de72ff2	\N	{}
fa931541-31de-4b9c-99be-afeb5710275a	products	produtos/shared/drive_12LFNgj--NT-k8ocAZWSxkpgy7HMy9WZc.jpg	\N	2025-12-17 22:07:47.036889+00	2026-03-16 23:12:23.272594+00	2025-12-17 22:07:47.036889+00	{"eTag": "\\"de5a0fa7fd54da125a99891c759bb6a6\\"", "size": 92764, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:24.000Z", "contentLength": 92764, "httpStatusCode": 200}	b62e6e54-6f4c-4e82-9452-be103b709876	\N	{}
5f3be1f7-c8e1-46b8-b905-990d059ad998	products	produtos/shared/drive_1nEk0CB_cjErsUT0ui4a1s1QluJovqcCE.jpg	\N	2025-12-17 22:07:49.79891+00	2026-03-16 23:12:26.203988+00	2025-12-17 22:07:49.79891+00	{"eTag": "\\"55b88bb91b0fc90d92d3150fd4ce1cc3\\"", "size": 94972, "mimetype": "image/jpeg", "cacheControl": "no-cache", "lastModified": "2026-03-16T23:12:27.000Z", "contentLength": 94972, "httpStatusCode": 200}	2d7ba120-5436-43a9-8999-50d00059ca61	\N	{}
\.


--
-- Data for Name: s3_multipart_uploads; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads (id, in_progress_size, upload_signature, bucket_id, key, version, owner_id, created_at, user_metadata, metadata) FROM stdin;
\.


--
-- Data for Name: s3_multipart_uploads_parts; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.s3_multipart_uploads_parts (id, upload_id, size, part_number, bucket_id, key, etag, owner_id, version, created_at) FROM stdin;
\.


--
-- Data for Name: vector_indexes; Type: TABLE DATA; Schema: storage; Owner: -
--

COPY storage.vector_indexes (id, name, bucket_id, data_type, dimension, distance_metric, metadata_configuration, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: secrets; Type: TABLE DATA; Schema: vault; Owner: -
--

COPY vault.secrets (id, name, description, secret, key_id, nonce, created_at, updated_at) FROM stdin;
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: -
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: categoria_id_categoria_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.categoria_id_categoria_seq', 25, true);


--
-- Name: contatos_id_contato_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.contatos_id_contato_seq', 14, true);


--
-- Name: cupons_id_cupom_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cupons_id_cupom_seq', 1, true);


--
-- Name: email_token_id_email_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.email_token_id_email_seq', 14, true);


--
-- Name: empresas_id_empresa_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.empresas_id_empresa_seq', 15, true);


--
-- Name: enderecos_id_endereco_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.enderecos_id_endereco_seq', 14, true);


--
-- Name: imagens_produto_id_imagem_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.imagens_produto_id_imagem_seq', 3435, true);


--
-- Name: itens_pedido_id_item_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.itens_pedido_id_item_seq', 66, true);


--
-- Name: pedidos_id_pedido_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.pedidos_id_pedido_seq', 16, true);


--
-- Name: precos_produto_id_preco_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.precos_produto_id_preco_seq', 1, false);


--
-- Name: produtos_id_produto_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.produtos_id_produto_seq', 3521, true);


--
-- Name: regioes_id_regiao_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.regioes_id_regiao_seq', 6, true);


--
-- Name: subcategoria_id_subcategoria_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subcategoria_id_subcategoria_seq', 47, true);


--
-- Name: vendedor_id_vendedor_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vendedor_id_vendedor_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: -
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 1, false);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: custom_oauth_providers custom_oauth_providers_identifier_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_identifier_key UNIQUE (identifier);


--
-- Name: custom_oauth_providers custom_oauth_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.custom_oauth_providers
    ADD CONSTRAINT custom_oauth_providers_pkey PRIMARY KEY (id);


--
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: webauthn_challenges webauthn_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_pkey PRIMARY KEY (id);


--
-- Name: webauthn_credentials webauthn_credentials_pkey; Type: CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_pkey PRIMARY KEY (id);


--
-- Name: categoria categoria_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_nome_key UNIQUE (nome);


--
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id_categoria);


--
-- Name: contatos contatos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contatos
    ADD CONSTRAINT contatos_pkey PRIMARY KEY (id_contato);


--
-- Name: cupons cupons_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cupons
    ADD CONSTRAINT cupons_codigo_key UNIQUE (codigo);


--
-- Name: cupons cupons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cupons
    ADD CONSTRAINT cupons_pkey PRIMARY KEY (id_cupom);


--
-- Name: email_token email_token_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_token
    ADD CONSTRAINT email_token_pkey PRIMARY KEY (id_email);


--
-- Name: email_token email_token_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_token
    ADD CONSTRAINT email_token_token_key UNIQUE (token);


--
-- Name: empresas empresas_cnpj_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_cnpj_key UNIQUE (cnpj);


--
-- Name: empresas empresas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT empresas_pkey PRIMARY KEY (id_empresa);


--
-- Name: enderecos enderecos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enderecos
    ADD CONSTRAINT enderecos_pkey PRIMARY KEY (id_endereco);


--
-- Name: imagens_produto imagens_produto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imagens_produto
    ADD CONSTRAINT imagens_produto_pkey PRIMARY KEY (id_imagem);


--
-- Name: itens_pedido itens_pedido_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT itens_pedido_pkey PRIMARY KEY (id_item);


--
-- Name: pedidos pedidos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT pedidos_pkey PRIMARY KEY (id_pedido);


--
-- Name: precos_produto precos_produto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.precos_produto
    ADD CONSTRAINT precos_produto_pkey PRIMARY KEY (id_preco);


--
-- Name: produtos produtos_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_codigo_key UNIQUE (codigo);


--
-- Name: produtos produtos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT produtos_pkey PRIMARY KEY (id_produto);


--
-- Name: regioes regioes_estado_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regioes
    ADD CONSTRAINT regioes_estado_key UNIQUE (estado);


--
-- Name: regioes regioes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.regioes
    ADD CONSTRAINT regioes_pkey PRIMARY KEY (id_regiao);


--
-- Name: subcategoria subcategoria_id_categoria_nome_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcategoria
    ADD CONSTRAINT subcategoria_id_categoria_nome_key UNIQUE (id_categoria, nome);


--
-- Name: subcategoria subcategoria_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcategoria
    ADD CONSTRAINT subcategoria_pkey PRIMARY KEY (id_subcategoria);


--
-- Name: vendedor vendedor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vendedor
    ADD CONSTRAINT vendedor_pkey PRIMARY KEY (id_vendedor);


--
-- Name: messages messages_payload_exclusive; Type: CHECK CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages
    ADD CONSTRAINT messages_payload_exclusive CHECK (((payload IS NULL) OR (binary_payload IS NULL))) NOT VALID;


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: -
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: custom_oauth_providers_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_created_at_idx ON auth.custom_oauth_providers USING btree (created_at);


--
-- Name: custom_oauth_providers_enabled_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_enabled_idx ON auth.custom_oauth_providers USING btree (enabled);


--
-- Name: custom_oauth_providers_identifier_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_identifier_idx ON auth.custom_oauth_providers USING btree (identifier);


--
-- Name: custom_oauth_providers_provider_type_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX custom_oauth_providers_provider_type_idx ON auth.custom_oauth_providers USING btree (provider_type);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: -
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- Name: webauthn_challenges_expires_at_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_expires_at_idx ON auth.webauthn_challenges USING btree (expires_at);


--
-- Name: webauthn_challenges_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_challenges_user_id_idx ON auth.webauthn_challenges USING btree (user_id);


--
-- Name: webauthn_credentials_credential_id_key; Type: INDEX; Schema: auth; Owner: -
--

CREATE UNIQUE INDEX webauthn_credentials_credential_id_key ON auth.webauthn_credentials USING btree (credential_id);


--
-- Name: webauthn_credentials_user_id_idx; Type: INDEX; Schema: auth; Owner: -
--

CREATE INDEX webauthn_credentials_user_id_idx ON auth.webauthn_credentials USING btree (user_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: -
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- Name: subscription_subscription_id_entity_filters_action_filter_selec; Type: INDEX; Schema: realtime; Owner: -
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_action_filter_selec ON realtime.subscription USING btree (subscription_id, entity, filters, action_filter, COALESCE(selected_columns, '{}'::text[]));


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- Name: idx_objects_bucket_id_name_lower; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX idx_objects_bucket_id_name_lower ON storage.objects USING btree (bucket_id, lower(name) COLLATE "C");


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: -
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: -
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- Name: categoria trigger_update_categoria; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_categoria BEFORE UPDATE ON public.categoria FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: contatos trigger_update_contatos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_contatos BEFORE UPDATE ON public.contatos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: cupons trigger_update_cupons; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_cupons BEFORE UPDATE ON public.cupons FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: empresas trigger_update_empresas; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_empresas BEFORE UPDATE ON public.empresas FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: enderecos trigger_update_enderecos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_enderecos BEFORE UPDATE ON public.enderecos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: imagens_produto trigger_update_imagens_produto; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_imagens_produto BEFORE UPDATE ON public.imagens_produto FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: itens_pedido trigger_update_itens_pedido; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_itens_pedido BEFORE UPDATE ON public.itens_pedido FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: pedidos trigger_update_pedidos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_pedidos BEFORE UPDATE ON public.pedidos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: precos_produto trigger_update_precos_produto; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_precos_produto BEFORE UPDATE ON public.precos_produto FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: produtos trigger_update_produtos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_produtos BEFORE UPDATE ON public.produtos FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: regioes trigger_update_regioes; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_regioes BEFORE UPDATE ON public.regioes FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: subcategoria trigger_update_subcategoria; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_subcategoria BEFORE UPDATE ON public.subcategoria FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: -
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- Name: buckets protect_buckets_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_buckets_delete BEFORE DELETE ON storage.buckets FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects protect_objects_delete; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER protect_objects_delete BEFORE DELETE ON storage.objects FOR EACH STATEMENT EXECUTE FUNCTION storage.protect_delete();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: -
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: webauthn_challenges webauthn_challenges_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_challenges
    ADD CONSTRAINT webauthn_challenges_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: webauthn_credentials webauthn_credentials_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: -
--

ALTER TABLE ONLY auth.webauthn_credentials
    ADD CONSTRAINT webauthn_credentials_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: contatos fk_contato_empresa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contatos
    ADD CONSTRAINT fk_contato_empresa FOREIGN KEY (id_empresa) REFERENCES public.empresas(id_empresa) ON DELETE CASCADE;


--
-- Name: email_token fk_email_token_empresa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_token
    ADD CONSTRAINT fk_email_token_empresa FOREIGN KEY (id_empresa) REFERENCES public.empresas(id_empresa) ON DELETE CASCADE;


--
-- Name: empresas fk_empresas_vendedor; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.empresas
    ADD CONSTRAINT fk_empresas_vendedor FOREIGN KEY (id_vendedor) REFERENCES public.vendedor(id_vendedor);


--
-- Name: enderecos fk_endereco_empresa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.enderecos
    ADD CONSTRAINT fk_endereco_empresa FOREIGN KEY (id_empresa) REFERENCES public.empresas(id_empresa) ON DELETE CASCADE;


--
-- Name: imagens_produto fk_imagem_produto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.imagens_produto
    ADD CONSTRAINT fk_imagem_produto FOREIGN KEY (id_produto) REFERENCES public.produtos(id_produto) ON DELETE CASCADE;


--
-- Name: itens_pedido fk_item_pedido; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT fk_item_pedido FOREIGN KEY (id_pedido) REFERENCES public.pedidos(id_pedido) ON DELETE CASCADE;


--
-- Name: itens_pedido fk_item_produto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.itens_pedido
    ADD CONSTRAINT fk_item_produto FOREIGN KEY (id_produto) REFERENCES public.produtos(id_produto);


--
-- Name: pedidos fk_pedido_cliente; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES public.empresas(id_empresa);


--
-- Name: pedidos fk_pedido_cupom; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pedidos
    ADD CONSTRAINT fk_pedido_cupom FOREIGN KEY (id_cupom) REFERENCES public.cupons(id_cupom);


--
-- Name: precos_produto fk_preco_produto; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.precos_produto
    ADD CONSTRAINT fk_preco_produto FOREIGN KEY (id_produto) REFERENCES public.produtos(id_produto) ON DELETE CASCADE;


--
-- Name: precos_produto fk_preco_regiao; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.precos_produto
    ADD CONSTRAINT fk_preco_regiao FOREIGN KEY (id_regiao) REFERENCES public.regioes(id_regiao) ON DELETE RESTRICT;


--
-- Name: produtos fk_produto_categoria; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT fk_produto_categoria FOREIGN KEY (id_categoria) REFERENCES public.categoria(id_categoria) ON DELETE RESTRICT;


--
-- Name: produtos fk_produto_subcategoria; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.produtos
    ADD CONSTRAINT fk_produto_subcategoria FOREIGN KEY (id_subcategoria) REFERENCES public.subcategoria(id_subcategoria) ON DELETE RESTRICT;


--
-- Name: subcategoria fk_subcategoria_categoria; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subcategoria
    ADD CONSTRAINT fk_subcategoria_categoria FOREIGN KEY (id_categoria) REFERENCES public.categoria(id_categoria) ON DELETE CASCADE;


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: -
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: -
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: -
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: objects public 1ifhysk_0; Type: POLICY; Schema: storage; Owner: -
--

CREATE POLICY "public 1ifhysk_0" ON storage.objects FOR SELECT USING (((bucket_id = 'products'::text) AND (lower((storage.foldername(name))[1]) = 'produtos'::text)));


--
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: -
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: -
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: -
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


--
-- PostgreSQL database dump complete
--

\unrestrict c81orbekjIo9jKPJq6RU4yzVAIYHxfkBGLVFlmGASQCq9ah300XB9Ws8tShbk3H

