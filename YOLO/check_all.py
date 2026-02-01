import sys
import time

print("=" * 60)
print("Step 1: Python / PyTorch / CUDA 检查")
print("=" * 60)

print("Python 版本:", sys.version.split()[0])

try:
    import torch
    print("PyTorch 版本:", torch.__version__)
    print("PyTorch CUDA 版本:", torch.version.cuda)
    print("CUDA 是否可用:", torch.cuda.is_available())

    if torch.cuda.is_available():
        print("GPU 数量:", torch.cuda.device_count())
        print("当前 GPU:", torch.cuda.get_device_name(0))
    else:
        print("❌ CUDA 不可用，后续步骤将失败")

except Exception as e:
    print("❌ PyTorch 导入失败")
    print(e)
    sys.exit(1)


print("\n" + "=" * 60)
print("Step 2: Ultralytics / YOLO 环境检查")
print("=" * 60)

try:
    import ultralytics
    from ultralytics import YOLO

    print("Ultralytics 版本:", ultralytics.__version__)
    model = YOLO("yolov8n.pt")
    print("YOLO 模型加载成功")

except Exception as e:
    print("❌ Ultralytics / YOLO 检查失败")
    print(e)
    sys.exit(1)


print("\n" + "=" * 60)
print("Step 3: GPU 实际推理测试")
print("=" * 60)

try:
    start = time.time()

    results = model.predict(
        source="https://ultralytics.com/images/bus.jpg",
        device=0,
        imgsz=640,
        verbose=True
    )

    end = time.time()

    print(f"推理完成，用时: {end - start:.2f} 秒")
    print("✅ GPU 推理成功（device=0）")

except Exception as e:
    print("❌ 推理失败（很可能没有用到 GPU）")
    print(e)
    sys.exit(1)


print("\n" + "=" * 60)
print("🎉 所有检查通过：环境完全正常")
print("=" * 60)
