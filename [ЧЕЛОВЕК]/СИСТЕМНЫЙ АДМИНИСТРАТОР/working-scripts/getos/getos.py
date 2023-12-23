import platform

def get_os():
    operating_system = platform.system()
    
    if operating_system == "Windows":
        print("Операционная система: Windows")
    elif operating_system == "Linux":
        print("Операционная система: Linux")
    elif operating_system == "Darwin":
        print("Операционная система: macOS")
    else:
        print("Не удалось определить операционную систему.")
        
get_os()
