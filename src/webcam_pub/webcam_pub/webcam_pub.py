import rclpy
from rclpy.node import Node
from sensor_msgs.msg import Image
from cv_bridge import CvBridge
import cv2


class WebCamPublisher(Node):
    def __init__(self, node_name: str, *, context: rclpy.Context = None, cli_args: rclpy.List[str] = None, namespace: str = None, use_global_arguments: bool = True, enable_rosout: bool = True, start_parameter_services: bool = True, parameter_overrides: rclpy.List[rclpy.Parameter] = None, allow_undeclared_parameters: bool = False, automatically_declare_parameters_from_overrides: bool = False) -> None:
        super().__init__(node_name, context=context, cli_args=cli_args, namespace=namespace, use_global_arguments=use_global_arguments, enable_rosout=enable_rosout, start_parameter_services=start_parameter_services, parameter_overrides=parameter_overrides, allow_undeclared_parameters=allow_undeclared_parameters, automatically_declare_parameters_from_overrides=automatically_declare_parameters_from_overrides)

        self.publisher_=self.create_publisher(Image,'image_raw',10)
        self.timer=self.create_timer(0.1,self.timerCallback)
        self.cap=cv2.VideoCapture(0)
        self.cvBridge=CvBridge()


    def timerCallback(self):
        ret,frame=self.cap.read()

        if ret:
            self.publisher_.publish(self.cvBridge.cv2_to_imgmsg(frame,'bgr8'))

        self.get_logger().info("Publishing video frame")


def main(args=None):
    rclpy.init(args=args)
    node=WebCamPublisher("webcamPublisher")
    rclpy.spin(node)
    node.destroy_node()
    rclpy.shutdown()