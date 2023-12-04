import os
def file_jpeg(n, text):
    first = 0
    last = 0
    for i in range(n, len(text)):
        if text[i:i+4] == "ffd8":
            first = i
        if text[i:i+4] == "ffd9":
            last = i + 4
        if first != 0 and last != 0:
            break
    a = []
    a.append(first)
    a.append(last)
    return a

output_directory = 'jpegs'
os.makedirs(output_directory, exist_ok=True)

try:
    with open('test.txt', 'r') as file_pcap:
        text = file_pcap.read() #text <- file with pcap in raw view
        first = 0 #first <- first index jpeg
        last = 0 #last <- last index jpeg
        index = 0
        count = 0 #count <- count of all jpeg
        c_count = 0 # c_count <- current jpeg
        count = text.count("ffd8")
        while c_count < count:
            el = []
            el = file_jpeg(index, text)
            new_text = ""
            first = el[0]
            last = el[1]
            for i in range(first, last):
                new_text += text[i]
            try:
                binary_data = bytes.fromhex(new_text)
            except:
                print(f"Error in file -> {c_count}, but program continue")
            output_path = os.path.join(output_directory, f'{index}.jpg')
            with open(output_path, 'wb') as output_file:
                output_file.write(binary_data)
            index = el[1]
            c_count += 1
    print("Program finish success")
except:
    print("Error")