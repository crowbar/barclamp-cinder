#
# Copyright 2011-2013, Dell
# Copyright 2013-2014, SUSE LINUX Products GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module Barclamp
  module CinderHelper
    def volume_type_for_cinder(selected)
      options_for_select(
        [
          [t(".volume.raw_volume_type"), "raw"],
          [t(".volume.local_volume_type"), "local"],
          [t(".volume.netapp_volume_type"), "netapp"],
          [t(".volume.emc_volume_type"), "emc"],
          [t(".volume.eqlx_volume_type"), "eqlx"],
          [t(".volume.eternus_volume_type"), "eternus"],
          [t(".volume.rbd_volume_type"), "rbd"],
          [t(".volume.manual_volume_type"), "manual"]
        ],
        selected.to_s
      )
    end

    def raw_methods_for_cinder(selected)
      options_for_select(
        [
          ["First Available", "first"],
          ["All Available", "all"]
        ],
        selected.to_s
      )
    end

    def netapp_storage_family(selected)
      options_for_select(
        [
          ["Data ONTAP in 7-Mode", "ontap_7mode"],
          ["Data ONTAP in Clustered Mode", "ontap_cluster"]
        ],
        selected.to_s
      )
    end

    def netapp_storage_protocol(selected)
      options_for_select(
        [
          ["iSCSI", "iscsi"],
          ["NFS", "nfs"]
        ],
        selected.to_s
      )
    end

    def netapp_transports_for_cinder(selected)
      options_for_select(
        [
          ["HTTP", "http"],
          ["HTTPS", "https"]
        ],
        selected.to_s
      )
    end

    def eternus_protocols_for_cinder(selected)
      options_for_select(
        [
          ["iSCSI", "iscsi"],
          ["FibreChannel", "fc"]
        ],
        selected.to_s
      )
    end

    def api_protocols_for_cinder(selected)
      options_for_select(
        [
          ["HTTP", "http"],
          ["HTTPS", "https"]
        ],
        selected.to_s
      )
    end
  end
end
