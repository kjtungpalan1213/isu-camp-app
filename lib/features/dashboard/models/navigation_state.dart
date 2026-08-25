enum NavigationFlowState {
  idle,
  currentLocation, // <-- Added for locate button popup
  placeSelected,
  chooseRoute,
  routeDetails,
  navigating,
  arrived,
}
