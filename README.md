# DevSpaceAuth
`DevSpaceAuth` is a wrapper around `Plug.BasicAuth` with rate limiting and global configuration.
It is designed to protect endpoints that are used only by developers.

## Installation

The package can be installed by adding `dev_space_auth` and `hammer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:dev_space_auth, github: "prosapient/dev_space_auth"},
    {:hammer, "~> 6.0"}
  ]
end
```

Configure Hammer:
```elixir
config :hammer,
  backend: {Hammer.Backend.ETS, [expiry_ms: 60_000 * 60 * 4,
                               cleanup_interval_ms: 60_000 * 10]}
```

Configure DevSpaceAuth:
```elixir
config :dev_space_auth,
  username: "username",
  password: "password"
```
