$(document).ready(function($) {
  $('#volume_volume_type').on('change', function() {
    var value = $(this).val();

    var types = [
      'emc',
      'netapp',
      'eqlx',
      'manual',
      'local',
      'rbd',
      'raw'
    ];

    var selector = $.map(types, function(val, index) {
      return '#{0}_container'.format(val);
    }).join(', ');

    var current = '#{0}_container'.format(
      value
    );

    $(selector).hide(100).attr('disabled', 'disabled');
    $(current).show(100).removeAttr('disabled');
  }).trigger('change');

  $('#volume_netapp_storage_protocol').on('change', function() {
      switch ($('#volume_netapp_storage_protocol').val()) {
        case 'nfs':
          $('#netapp_nfs_container').show(100).removeAttr('disabled');
          break;
        default:
          $('#netapp_nfs_container').hide(100).attr('disabled', 'disabled');
          break;
      }
  }).trigger('change');
});
