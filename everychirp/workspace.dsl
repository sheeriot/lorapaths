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
            }

            power = container "power" "gateway power" "hardware" powertag
        }

        networkserver = softwareSystem "Network Server" "LoRaWAN NS" nstag {
            routing = container "Routing" "Traffic Router" "software" routertag 
            pkt-bridge = container "Packet Bridge" "Gateway Connector" "daemon" bridgetag {
                this -> routing uplinks
                routing -> this downlinks
            }
            dedup = container "DeDup" "LoRaWAN NS" "software" deduptag {
                routing -> this
            }
            mac = container "MAC" "Media Access Control" "software" nsmactag {
                routing -> this
                this -> routing
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
            provision = container "Provision" "Fleet Manager" "software" provisiontag {
                this -> networkserver.join
            }
            decrypt = container "Decrypt" "Decryption" "software" decrypttag {
                networkserver.join -> this appSkey
            }
            decode = container "Decode" "Playload Decoding" ""
        }
        
        device.antenna -> gateway.antenna uplinks RF uplink
        gateway.antenna -> device.antenna downlinks RF downlink
        
        gateway.backhaul -> networkserver.pkt-bridge uplinks ip-tunnel uplink
        networkserver.pkt-bridge -> gateway.backhaul downlinks ip-tunnel downlink

        device.mcu -> networkserver.mac "LoRaWAN\nMAC" control logical
        networkserver.mac -> device.mcu "LoRaWAN\nMAC" control logical

        networkserver -> applicationserver uplinks http uplink
        applicationserver -> networkserver downlink http downlink

        device.mcu -> applicationserver reports uplink logical
        applicationserver -> device.mcu control downlink logical
        
    }

    views {
    
        systemContext device LoRaWAN "LoraWan Packet Flow" {
            include *
        }
        
        container device device_CONTAINERS "LoraWan Device" {
            include *
        }
        
        container gateway gateway_CONTAINERS "LoraWan Gateway" {
            include *
        }

        container networkserver networkserver_CONTAINERS "LoraWan Network Server" {
            include *
            # include applicationserver
        }

        styles {
            relationship uplink {
                color LimeGreen
                dashed false
                thickness 4
            }
            relationship downlink {
                color red
                dashed false
                thickness 4
            }
            relationship logical {  
                color blue
                dashed true
                thickness 4
            }
            element devtag {
                background green
                color white
                fontSize 24
                shape Hexagon
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
                color #ffffff
                fontSize 24
                shape Cylinder
            }
            element bridgetag {
                background #BDB5D5
                color black
                icon docs/icons/bridge_icon.png
            }
            element jointag {
                # background #BDB5D5
                # color #ffffff
                # icon docs/icons/bridge.png
                shape Cylinder
            }
            element nsmactag {
                icon docs/icons/accesscontrol_icon.png
            }
            element adrtag {
                icon docs/icons/lever_icon.png
            }
            element routertag {
                background aqua
                # color #ffffff
                icon docs/icons/router_icon.png
                # shape Cylinder
            }
            element astag {
                background darkolivegreen
                color white
                fontSize 24
                shape RoundedBox
            }
            element sensorstag {
                background green
                color white
                fontSize 24
                shape Hexagon
                # icon docs/images/therm100.jpg
            }
            element antennatag {
                background #DA70D6
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element radiotag {
                background violet
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element modemtag {
                background  #E0B0FF
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element cputag {
                background LightGreen
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element powertag {
                background IndianRed
                color white
                shape Component
                # icon docs/images/antenna.png
            }
            element gpstag {
                background SkyBlue
                color black
                shape Component
                # icon docs/images/antenna.png
            }
            element pktfwdtag {
                # background #DF73FF
                color white
                shape Component
                # icon docs/images/antenna.png
            }
            element backhaultag {
                # background #4E2A84
                color white
                shape Component
                # icon docs/images/antenna.png
            }
        }
    }

}