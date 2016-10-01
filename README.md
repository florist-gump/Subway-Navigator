# Subway Navigator

Subway Navigator is an iOS application that enables underground public transport navigation in settings where navigation usually, due to the lack of GPS, would not be possible by utilizing embedded smartphone sensors such as the accelerometer.

<img src="https://raw.githubusercontent.com/florist-gump/Subway-Navigator/master/SubNav/Navigate.jpg" width="500">

Subway Navigator is a proof of concept application that underground public transport is possible. The application allows its users to navigate the Glasgow subway, even if they are unfamiliar with the subway system or are not paying attention to their current position. The application gives position and direction information and allows its users to better navigate the subway by giving them a comprehensible overview of their journey, an estimated arrival time as well as the option of getting notified when it is time to disembark from the train.

The application uses a neural network to infer the current motion state of the subway by analysing the sensor readings from the smartphone's accelerometers and gyroscopes. This information is than used to infer the current position of the subway.
