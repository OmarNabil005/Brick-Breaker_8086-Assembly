from PIL import Image
import sys

D = {
    (0, 0, 170): 1,
    (0, 170, 0): 2,
    (0, 170, 170): 3,
    # ... (trimmed for brevity, include the full dictionary here) ...
    (45, 49, 65): 247
}

print("INPUT IMAGE NAME")
file_name = input().strip()

try:
    with Image.open(file_name) as img:
        img = img.convert("RGBA")  # Ensure the image is in RGBA mode
        img.load()
except FileNotFoundError:
    print(f"Error: File '{file_name}' not found.")
    sys.exit(1)
except Exception as e:
    print(f"Error opening file: {e}")
    sys.exit(1)

while True:
    print("#" * 50)
    print("MENU OPTIONS:\n")
    print("1- Convert To Binary File")
    print("2- Resize The Image")
    print("3- Exit")

    try:
        option = int(input("Option: "))
    except ValueError:
        print("Invalid input. Please enter a number.")
        continue

    if option == 3:
        print("Exiting...")
        break

    elif option == 2:
        try:
            factor = int(input("INPUT HOW MANY TIMES DO YOU WANT TO REDUCE IT: "))
            img = img.reduce(factor)
            print(f"Image resized by a factor of {factor}.")
        except Exception as e:
            print(f"Error resizing image: {e}")

    elif option == 1:
        pixels = list(img.getdata())
        converted = []

        for pixel in pixels:
            if pixel[3] == 0:  # Check alpha channel
                converted.append(250)
            elif pixel[:3] in D.keys():
                converted.append(D[pixel[:3]])
            else:
                min_diff = float('inf')
                closest_key = None
                for k in D.keys():
                    diff = sum(abs(k[i] - pixel[i]) for i in range(3))
                    if diff < min_diff:
                        min_diff = diff
                        closest_key = k
                converted.append(D[closest_key])

        binary_data = bytes(converted)
        output_file = file_name.rsplit('.', 1)[0] + '.bin'

        try:
            with open(output_file, 'wb') as binary_file:
                binary_file.write(binary_data)
            print(f"Binary file '{output_file}' created successfully.")
        except Exception as e:
            print(f"Error writing binary file: {e}")

    else:
        print("Invalid option. Please try again.")