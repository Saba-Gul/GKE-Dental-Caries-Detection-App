from ultralytics import YOLO

# Load YOLOv8 model with custom weights
def load_model():
    #return YOLO('C:\\Users\\Saba Gul\\Desktop\\Caries-Detection\\data\\best.pt')  # use this path for direct run
    return YOLO('/app/data/best.pt')  # Use the path inside the container
