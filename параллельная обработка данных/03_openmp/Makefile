CXXFLAGS := -O3 -Wall -MD -fopenmp
TARGET := firstprivate
SRCS := main.cpp
OBJ_DIR := obj
OBJECTS := $(SRCS:%.cpp=$(OBJ_DIR)/%.o)
LDFLAGS := -lpthread

all: $(TARGET)

clean:
	rm -rf $(OBJ_DIR) $(TARGET)

$(OBJ_DIR)/%.o: %.cpp
	@mkdir -p $(OBJ_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET): $(OBJECTS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $(TARGET) $^

-include $(OBJECTS:.o=.d)