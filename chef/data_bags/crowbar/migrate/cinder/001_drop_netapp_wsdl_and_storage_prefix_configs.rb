def upgrade ta, td, a, d
  a.delete('netapp_wsdl_url')
  a.delete('netapp_storage_service')
  a.delete('netapp_storage_service_prefix')
  return a, d
end

def downgrade ta, td, a, d
  a['netapp_wsdl_url'] = 'http://192.168.124.11:8088/'
  a['netapp_storage_service'] = ''
  a['netapp_storage_service_prefix'] = 'crowbar_'
  return a, d
end
