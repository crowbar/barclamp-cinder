def upgrade ta, td, a, d
  a["volume"]["eqlx"].delete('eqlx_ssh_keepalive_interval')
  return a, d
end

def downgrade ta, td, a, d
  a["volume"]["eqlx"]['eqlx_ssh_keepalive_interval'] = 1200
  return a, d
end
