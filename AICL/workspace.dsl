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
            pkt-bridge = container "Packet Bridge" "IP to RF" "daemon" pktbridgetag
            dedup = container "DeDup" "LoRaWAN NS" "software" deduptag
            mac = container "MAC" "Media Access Control" "software" nsmactag
            join = container "Join" "LoRaWAN NS" "software" jointag
            integrations = container "integrations" "LoRaWAN NS" "software" fwdtag
            adr = container "ADR" "LoRaWAN NS" "software" adrtag
        }

        applicationserver = softwareSystem "Application Server" "data/control" astag
        
        device.antenna -> gateway.antenna uplinks RF uplink
        device.mcu -> networkserver.mac "LoRaWAN\nMAC" uplink logical
        networkserver.mac -> device.mcu "LoRaWAN\nMAC" downlink logical
        device.mcu -> applicationserver reports uplink logical
        gateway -> networkserver uplinks pkt-fwd uplink
        networkserver -> applicationserver uplinks http uplink
        applicationserver -> networkserver downlink http downlink
        networkserver -> gateway downlink pkt-fwd downlink
        gateway.antenna -> device.antenna downlinks RF downlink
        applicationserver -> device.mcu control downlink logical
        gateway.pktfwd -> networkserver.pkt-bridge encaps uplink tunnel
        networkserver.pkt-bridge -> gateway.pktfwd encaps downlink tunnel
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
                # icon docs/images/tower.png
            }
            element nstag {
                // wisteria
                background #BDB5D5
                color #ffffff
                fontSize 24
                shape Cylinder
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