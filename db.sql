-- 1. Create the users table (if using public.users instead of just auth.users)
CREATE TABLE public.users (
  uid uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text NOT NULL,
  username text NOT NULL,
  profile_pic text NOT NULL
);

-- 2. Create the stadiums table
CREATE TABLE public.stadiums (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  capacity INTEGER NOT NULL,
  seat_map JSONB NOT NULL  -- stores Map<String, List<int>>
);

-- 3. Create the matches table
CREATE TABLE public.matches (
  match_id UUID PRIMARY KEY,
  home_team TEXT NOT NULL,
  away_team TEXT NOT NULL,
  stadium_id UUID NOT NULL REFERENCES stadiums(id),
  timestamp TIMESTAMP NOT NULL
);

-- 4. Create the prices table
CREATE TABLE public.prices (
  id UUID PRIMARY KEY,
  vvip DOUBLE PRECISION NOT NULL,
  vipa DOUBLE PRECISION NOT NULL,
  vipb DOUBLE PRECISION NOT NULL,
  vipc DOUBLE PRECISION NOT NULL,
  orange DOUBLE PRECISION NOT NULL,
  round DOUBLE PRECISION NOT NULL,
  match_id UUID NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE
);

-- 5. Create the tickets table
CREATE TABLE public.tickets (
  ticket_no TEXT PRIMARY KEY,
  match UUID NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
  timestamp TIMESTAMP NOT NULL,
  amount DOUBLE PRECISION NOT NULL,
  seat_type TEXT NOT NULL,
  seat_no INTEGER NOT NULL,
  is_cancelled BOOLEAN DEFAULT FALSE,
  uid UUID NOT NULL REFERENCES auth.users(id)
);

-- 6. Create the sales table
CREATE TABLE public.sales (
  id UUID PRIMARY KEY,
  ticket_no JSONB NOT NULL,     -- stores List<String>
  seat_no JSONB NOT NULL,       -- stores List<int>
  seat_type TEXT NOT NULL,
  match_id UUID NOT NULL REFERENCES matches(match_id) ON DELETE CASCADE,
  stadium_id UUID NOT NULL REFERENCES stadiums(id) ON DELETE CASCADE
);
