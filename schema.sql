/**
* RECOMMENDATIONS
* Note: this table tracks all the recommendations for things to eat, do, learn.
* Requires PostGIS. To enable head to https://app.supabase.io/project/{id}/database/extensions
*/
create type recommendation_category as enum ('eat', 'do', 'learn');
create type cost_type as enum ('free', 'paid');
create table recommendations (
  id bigint generated by default as identity primary key,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null,
  title text not null,
  description text not null,
  url text not null unique,
  image_url text not null,
  category recommendation_category,
  location geography(point), -- insert into recommendations (location) values ('SRID=4326;POINT(longitude latitude)');
  source text,
  cost cost_type,
  clicks bigint default 0,
  downvotes bigint default 0,
  expiration_date timestamp with time zone,
  approved boolean default false,
  channel text,
  metadata jsonb
)
/**
* Enable Row Level Security
*/
alter table recommendations enable row level security;
CREATE POLICY "Enable public read access" ON public.recommendations FOR SELECT USING (true);
CREATE POLICY "Enable insert for users based on email" ON public.recommendations FOR INSERT WITH CHECK ((email() = 'admin@test.sg'::text));
CREATE POLICY "Enable update for users based on email" ON public.recommendations FOR UPDATE USING (auth.email() = 'admin@test.sg') WITH CHECK (auth.email() = 'admin@test.sg');
CREATE POLICY "Enable delete for users based on email" ON public.recommendations FOR DELETE USING (auth.email() = 'admin@test.sg');

/**
* INCREMENT HELPER FUNCTIONS
* We increment clicks or downvotes via an RPC to this function.
*/
create function increment_clicks (rec_id int) 
returns void as
$$
  update recommendations 
  set clicks = clicks + 1 -- increments is done here
  where id = rec_id
$$ 
language sql volatile;

create function increment_downvotes (rec_id int) 
returns void as
$$
  update recommendations 
  set downvotes = downvotes + 1 -- increments is done here
  where id = rec_id
$$ 
language sql volatile;