workspace "LoRaWAN Primer" "Quick-Start and Shared Reference Content for LoRaWANers" {

    !identifiers hierarchical
    !docs docs
    
    model {

        device = softwareSystem "LoRaWAN Device" "a device in the world" devtag {
            sensors = container "Physical Sensors" "get data" "hardware" sensorstag
            mcu = container "MicroControlUnit" "operate device" "hardware" mcutag {
                sensors -> this telemetry
            }
            modem = container "Modem" "communicate" "hardware" modemtag {
                mcu -> this comm-out
                this -> mcu comm-in
            }
            radio = container "Radio" "RF" "chip" radiotag {
                modem -> this out
                this -> modem in
            }
            antenna = container "Antenna" "" "hardware" antennatag {
                radio -> this out
                this -> radio in
            }
            power = container "power" "" "hardware" powertag
        }

        gateway = softwareSystem "LoRaWAN Gateway" "RF Coverage" gwtag {
            backhaul = container "Backhaul" "IP to Network Server" "internet" backhaultag   
            pktfwd = container "Packet Forwarder" "RF to IP" "daemon" pktfwdtag {
                -> backhaul internet cellular
            }
            cpu = container "CPU" "gateway" "hardware" cputag {
                -> pktfwd control
            }

            gps = container "GPS" "Geolocation" "" gpstag {
                cpu -> this
            }
            modem = container "Modem" "communicate" "hardware" modemtag {
                pktfwd -> this downlinks
                this -> pktfwd uplinks
            }
            radio = container "Radio" "RF" "chip" radiotag {
                modem -> this out
                this -> modem in
            }
            antenna = container "Antenna" "" "hardware" antennatag {
                radio -> this out
                this -> radio in
                device.antenna -> this uplinks RF uplink
                this -> device.antenna downlinks RF downlink
            }
            power = container "power" "gateway power" "hardware" powertag
        }

        networkserver = softwareSystem "Network Server" "LoRaWAN NS" nstag {
            routing = container "Routing" "Traffic Router" "software" routertag 
            pkt-bridge = container "Packet Bridge" "Gateway Connector" "daemon" bridgetag {
                this -> routing uplinks
                routing -> this downlinks
                gateway.backhaul -> this uplinks ip-tunnel uplink
                this -> gateway.backhaul downlinks ip-tunnel downlink
            }
            dedup = container "DeDup" "LoRaWAN NS" "software" deduptag {
                routing -> this
            }
            mac = container "MAC" "Media Access Control" "software" nsmactag {
                routing -> this
                this -> routing
                device.mcu -> this MAC control mac
                this -> device.mcu MAC control mac
            }
            join = container "Join" "LoRaWAN NS" "software" jointag {
                routing -> this
            }
            integrations = container "Integrations" "LoRaWAN NS" "software" nsfwdtag {
                routing -> this
            }
            adr = container "ADR" "LoRaWAN NS" "software" adrtag {
                this -> mac
            }
        }

        applicationserver = softwareSystem "Application Server" "data/control" astag {
            encrypt = container "Encrypt/Decrypt" "encrypt/decrypt" encryption encrypttag {
                device.mcu -> this reports uplink logical
                this -> device.mcu control downlink logical
                networkserver.integrations -> this uplinks HTTP uplink
                this -> networkserver.integrations downlinks HTTP downlink
            }
            decode = container "Decode" "Playload Decoding" decoder decodetag {
                encrypt -> this Payload
            }
            provision = container "Provision" "Fleet Manager" "software" provisiontag {
                this -> networkserver.join provision
                networkserver.join -> this appSkey joined
                this -> encrypt appSkey
            }
        }

        storageserver = softwareSystem "Storage Server" store storagetag

    }

    views {

        systemContext device device_system "LoraWan Packet Flow" {
            include *
        }
        systemContext applicationserver LoRaWAN2 "LoraWan Packet Flow - AS" {
            include *
            include gateway
            include storageserver
        }
        container device device_CONTAINERS "LoraWan Device" {
            include *
        }
        
        container gateway gateway_CONTAINERS "LoraWan Gateway" {
            include *
            include applicationserver
        }

        container networkserver networkserver_CONTAINERS "LoraWan Network Server" {
            include *
            # include applicationserver.encrypt
        }
        container applicationserver applicationserver_CONTAINERS "LoraWan Application Server" {
            include *
            include gateway
        }

        styles {
            relationship uplink {
                color DarkGreen
                dashed false
                thickness 4
            }
            relationship downlink {
                color Blue
                dashed false
                thickness 4
            }
            relationship logical {  
                color DarkOliveGreen
                dashed true
                thickness 4
            }
            relationship mac {  
                color orange
                dashed true
                thickness 4
            }
            element devtag {
                background #35D85D
                shape roundedbox
                icon docs/icons/therm_icon.png
                strokewidth 5
            }
            element gwtag {
                // periwinkle
                background #CCCCFF
                color black
                fontSize 24
                shape Pipe
                icon docs/icons/tower_icon.png
            }
            element nstag {
                // wisteria
                background #BDB5D5
                color black
                fontSize 24
                shape Cylinder
                icon docs/icons/service_icon.png
            }
            element bridgetag {
                background #BDB5D5
                shape pipe
                icon docs/icons/bridge_icon.png
            }
            element jointag {
                background  #F4EB30
                # color #ffffff
                icon docs/icons/lock_icon.png
                shape Cylinder
            }
            element provisiontag {
                background #FDDA0D
                icon docs/icons/tickets_icon.png
            }
            element encrypttag {
                background #FAA0A0
                icon docs/icons/lockandkey_icon.png
            }
            element decodetag {
                background #AFE1AF
                icon docs/icons/structure_icon.png
            }
            element nsmactag {
                background   #ff694f
                shape ellipse
                icon docs/icons/accesscontrol_icon.png
            }
            element adrtag {
                background  #FEBE10
                shape circle
                height 300
                width 300
                icon docs/icons/lever_icon.png
            }
            element deduptag {
                background  #aa9499
                color white
                shape ellipse
                icon docs/icons/deduplication_icon.png
            }
            element routertag {
                background  #89cff0
                # color #ffffff
                icon docs/icons/router_icon.png
                # shape Cylinder
            }
            element nsfwdtag {
                background #7CB9E8
                icon docs/icons/connector_icon.png
                shape Pipe
            }
            element astag {
                background #AFE1AF
                # color black
                fontSize 24
                shape RoundedBox
                icon docs/icons/pipes2_icon.png
            }
            element sensorstag {
                background green
                color white
                fontSize 24
                shape Hexagon
                icon docs/icons/therm100.jpg
            }
            element antennatag {
                background #DA70D6
                color black
                shape Component
                icon docs/icons/omni_icon.png
            }
            element radiotag {
                background violet
                color black
                shape Component
                icon docs/icons/radio_icon.png
            }
            element modemtag {
                background  #E0B0FF
                color black
                shape Component
                icon docs/icons/shuttlebus_icon.png
            }
            element mcutag {
                background LightGreen
                color black
                shape Component
                icon docs/icons/cpu_icon.png
            }
            element cputag {
                background LightGreen
                shape Component
                icon docs/icons/cpu_icon.png
            }
            element powertag {
                background #FAA0A0
                shape component
                icon docs/icons/power_icon.png
            }
            element gpstag {
                background skyblue
                shape roundedbox
                icon docs/icons/gps_icon.png
            }
            element pktfwdtag {
                background #A7C7E7
                # color white
                shape Pipe
                icon docs/icons/forward_icon.png
            }
            element backhaultag {
                background lightblue
                # color white
                shape Pipe
                icon docs/icons/globe_icon.png
            }
        }
    }
    # shape <Box|RoundedBox|Circle|Ellipse|Hexagon|Cylinder|Pipe|Person|Robot|Folder|
    #       WebBrowser|MobileDevicePortrait|MobileDeviceLandscape|Component>


}