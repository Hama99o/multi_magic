import moment from "moment";
import { v4 as uuidv4 } from "uuid";

export default {
  capitalize(value) {
    if (!value) return ''
    value = value.toString()
    return value.charAt(0).toUpperCase() + value.slice(1)
  },
  upcase(value) {
    if (!value) return ''
    value = value.toString()
    return value.toUpperCase()
  },
  downcase(value) {
    if (!value) return ''
    value = value.toString()
    return value.toLowerCase()
  },
  plural(value) {
    if (!value || value == 0 || value == 1) return ''
    return 's'
  },
  cleanUnderscore(value) {
    if (!value) return ''
    return value.replace(/_/g, ' ').trim()
  },
  convert_hr(value) {
    if (!value) return ''
    if (value == 'hr') {
      return 'admin'
    } else {
      return value
    }
  },
  truncateN(value, n = 65) {
    if (!value) return ''
    if (value.length > n) {
      return value.slice(0, (n - 1)) + '...'
    } else {
      return value
    }
  },
  compareDates(startDate, endDate, formatStr = "DD MMM, YYYY") {
    if (!startDate || !endDate) return false
    var startDateFormatted = moment(new Date(startDate)).format(formatStr)
    var endDateFormatted = moment(new Date(endDate)).format(formatStr)
    return moment(startDateFormatted, formatStr).isAfter(moment(endDateFormatted, formatStr));
  },
  formatDate(value, formatStr = "DD MMM, YYYY", initialFormatStr = "YYYY-MM-DD HH:mm:ss [UTC]" ) {
    if (!value || value.length === 0)
      return "Invalid date"
    if (typeof value === 'number')
      return moment(value).format(formatStr)
    if (value.split('/').length === 3) {
      return moment(value, "DD/MM/YYYY").format(formatStr)
    } else if (value.split('T').length === 2) {
      return moment(value.split('T')[0], "YYYY-MM-DD").format(formatStr)
    } else if (value.includes('UTC') || value.includes('+')) {
      return moment(value, initialFormatStr).format(formatStr)
    } else if (value.split('-').length === 3) {
      return moment(value).format(formatStr)
    }
  },
  formatDateHours(value, formatStr = "DD MMM, YYYY HH mm ss") {
    return moment(value).format(formatStr)
  },
  formatHours(value, formatStr = "HH mm ss") {
    return moment(value).format(formatStr)
  },
  formatDateHoursWithoutSeconds(value, formatStr = "DD MMM YYYY, HH[h]mm") {
    return moment(value).format(formatStr)
  },
  formatDateHoursWithAmPm(value, formatStr = "hh A", initialFormatStr = "YYYY-MM-DD HH:mm:ss [UTC]") {
    return moment(value, initialFormatStr).format(formatStr)
  },
  formatSpecificDate(value, initialFormat, resultFormat) {
    return moment(value, initialFormat).format(resultFormat)
  },
  formatSpecificDateCalendar(value, initialFormat) {
    return moment(value, initialFormat).calendar(null,{
      lastDay : '[Yesterday] hh:mma',
      sameDay : '[Today] hh:mma',
      nextDay : '[Tomorrow] hh:mma',
      lastWeek : '[last] dddd hh:mma',
      nextWeek : 'dddd hh:mma',
      sameElse : 'L'
    })
  },
  generateUniqueId() {
    return uuidv4()
  },
}
