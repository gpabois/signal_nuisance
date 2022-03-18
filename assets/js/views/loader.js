import ReportingLiveView from './reporting_live';

const views = {
    ReportingLiveView
};

export default function loadView(viewName) {
    return views[viewName] || MainView;
  }