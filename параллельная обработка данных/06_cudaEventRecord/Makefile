TARGET := cudaEventRecord
CC := nvcc

all: $(TARGET)

.PHONY : clean
clean:
	rm -rf $(TARGET)

$(TARGET): main.cu
	$(CC) $^ -o $(TARGET)

