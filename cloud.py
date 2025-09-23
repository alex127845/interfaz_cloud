import subprocess
import sys

def run_command(command):
    """Ejecuta un comando en el shell"""
    try:
        subprocess.run(command, check=True, shell=True)
        print(f"Comando ejecutado: {command}")
    except subprocess.CalledProcessError as e:
        print(f"Error ejecutando el comando: {command}\n{e}")
        sys.exit(1)

def create_instances(num_instances):
    """Crea el namespace, las interfaces TAP, el puente OVS y las instancias de QEMU"""
    print("\nCreando el namespace 'ns-dhcp-server' y las instancias de QEMU...")

    # Paso 1: Crear el namespace para el servidor DHCP
    run_command("ip netns add ns-dhcp-server")
    # Crear el puente OVS
    run_command("ovs-vsctl add-br ovs1")

    # Crear interfaces TAP según el número de instancias
    for i in range(1,num_instances+1):
        run_command(f"ip tuntap add mode tap name ovs1-tap{i}")  # Crear interfaces TAP

    # Crear las instancias de QEMU
    for i in range(1,num_instances+1):
        tap_name = f"ovs1-tap{i}"
        mac_address = f"20:20:64:66:ee:{i:02x}"  # Dirección MAC única
        qemu_command = f"qemu-system-x86_64 -enable-kvm -vnc 0.0.0.0:{i} " \
                       f"-netdev tap,id={tap_name},ifname={tap_name},script=no,downscript=no " \
                       f"-device e1000,netdev={tap_name},mac={mac_address} " \
                       f"-daemonize -snapshot " \
                       f"cirros-0.5.1-x86_64-disk.img"
        run_command(qemu_command)
    
    for i in range(1,num_instances+1):
        run_command(f"ovs-vsctl add-port ovs1 ovs1-tap{i}")

    run_command(f"ovs-vsctl add-port ovs1 ovs1-tap0 -- set interface ovs1-tap0 type=internal")

    # Configurar el servidor DHCP
    create_dhcp_server(num_instances)

def create_dhcp_server(num_instances):
    """Configura el servidor DHCP"""
    print("\nConfigurando el servidor DHCP...")
    run_command("ip link set ovs1-tap0 netns ns-dhcp-server")
    run_command("ip netns exec ns-dhcp-server ip link set dev lo up")
    run_command("ip netns exec ns-dhcp-server ip link set dev ovs1-tap0 up")

    for i in range(1,num_instances+1):
        run_command(f"ip link set dev ovs1-tap{i} up")

    run_command("ip link set dev ovs1 up")  
    run_command("ip netns exec ns-dhcp-server ip address add 10.0.0.14/29 dev ovs1-tap0")
    run_command("ip address add 10.0.0.9/29 dev ovs1")
    run_command("ip netns exec ns-dhcp-server dnsmasq --interface=ovs1-tap0 --dhcp-range=10.0.0.10,10.0.0.13,255.255.255.248 --dhcp-option=3,10.0.0.9")
    print("Servidor DHCP configurado.")

def delete_all(num_instances):
    """Elimina todo: namespaces, interfaces, OVS, instancias y procesos"""
    print("\nEliminando el namespace 'ns-dhcp-server' y limpiando configuración...")
    
    # Eliminar namespace y redes
    run_command("ip netns del ns-dhcp-server")  # Eliminar namespace
    run_command("ovs-vsctl del-br ovs1")  # Eliminar puente OVS

    # Eliminar interfaces TAP dinámicamente basadas en el número de instancias
    for i in range(num_instances+1):  # Asumimos que las interfaces TAP son 3 (o más, según el número de instancias)
        run_command(f"ip link del ovs1-tap{i}")  # Eliminar interfaces TAP
    
    # Eliminar la regla de iptables (masquerading NAT)
    run_command("iptables -s 10.0.0.8/29 -t nat -D POSTROUTING -j MASQUERADE")
    
    run_command("vm_proc_list=$(ps aux | grep qemu | grep kvm | awk '{print $2}')")
    run_command("for i in $vm_proc_list; do kill -9 $i; done")
    run_command("dhcp_proc_list=$(ps aux | grep dhcp | grep dnsmasq | awk '{print $2}')")
    run_command("for i in $dhcp_proc_list; do kill -9 $i; done")
    print("Todo eliminado: namespace, interfaces, OVS, reglas iptables y procesos detenidos.")

def show_menu():
    """Muestra el menú de opciones"""
    while True:
        print("\n--- Menú ---")
        print("1. Crear namespace, instancias y configurar DHCP")
        print("2. Eliminar namespace, interfaces, OVS y procesos")
        print("3. no c")
        print("4. Salir")
        
        option = input("Seleccione una opción (1-4): ")

        if option == '1':
            try:
                num_instances = int(input("Ingrese el número de instancias a crear: "))
                create_instances(num_instances)
            except ValueError:
                print("Por favor, ingrese un número válido.")
        elif option == '2':
            try:
                num_instances = int(input("Ingrese el número de instancias a crear: "))
                delete_all(num_instances)
            except ValueError:
                print("Por favor, ingrese un número válido.")
        elif option == '3':
            print("en proceso")
        elif option == '4':
            print("Saliendo...")
            break
        else:
            print("Opción no válida, intente de nuevo.")


if __name__ == "__main__":
    show_menu()
