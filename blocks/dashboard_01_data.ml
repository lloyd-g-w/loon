open! Core

type t =
  { id : int
  ; header : string
  ; type_ : string
  ; status : string
  ; target : string
  ; limit : string
  ; reviewer : string
  }
[@@deriving sexp_of, equal]

let all =
  [ { id = 1
    ; header = "Cover page"
    ; type_ = "Cover page"
    ; status = "In Process"
    ; target = "18"
    ; limit = "5"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 2
    ; header = "Table of contents"
    ; type_ = "Table of contents"
    ; status = "Done"
    ; target = "29"
    ; limit = "24"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 3
    ; header = "Executive summary"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "10"
    ; limit = "13"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 4
    ; header = "Technical approach"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "27"
    ; limit = "23"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 5
    ; header = "Design"
    ; type_ = "Narrative"
    ; status = "In Process"
    ; target = "2"
    ; limit = "16"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 6
    ; header = "Capabilities"
    ; type_ = "Narrative"
    ; status = "In Process"
    ; target = "20"
    ; limit = "8"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 7
    ; header = "Integration with existing systems"
    ; type_ = "Narrative"
    ; status = "In Process"
    ; target = "19"
    ; limit = "21"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 8
    ; header = "Innovation and Advantages"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "25"
    ; limit = "26"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 9
    ; header = "Overview of EMR's Innovative Solutions"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "7"
    ; limit = "23"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 10
    ; header = "Advanced Algorithms and Machine Learning"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "30"
    ; limit = "28"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 11
    ; header = "Adaptive Communication Protocols"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "9"
    ; limit = "31"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 12
    ; header = "Advantages Over Current Technologies"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "12"
    ; limit = "0"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 13
    ; header = "Past Performance"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "22"
    ; limit = "33"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 14
    ; header = "Customer Feedback and Satisfaction Levels"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "15"
    ; limit = "34"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 15
    ; header = "Implementation Challenges and Solutions"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "3"
    ; limit = "35"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 16
    ; header = "Security Measures and Data Protection Policies"
    ; type_ = "Narrative"
    ; status = "In Process"
    ; target = "6"
    ; limit = "36"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 17
    ; header = "Scalability and Future Proofing"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "4"
    ; limit = "37"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 18
    ; header = "Cost-Benefit Analysis"
    ; type_ = "Plain language"
    ; status = "Done"
    ; target = "14"
    ; limit = "38"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 19
    ; header = "User Training and Onboarding Experience"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "17"
    ; limit = "39"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 20
    ; header = "Future Development Roadmap"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "11"
    ; limit = "40"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 21
    ; header = "System Architecture Overview"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "24"
    ; limit = "18"
    ; reviewer = "Maya Johnson"
    }
  ; { id = 22
    ; header = "Risk Management Plan"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "15"
    ; limit = "22"
    ; reviewer = "Carlos Rodriguez"
    }
  ; { id = 23
    ; header = "Compliance Documentation"
    ; type_ = "Legal"
    ; status = "In Process"
    ; target = "31"
    ; limit = "27"
    ; reviewer = "Sarah Chen"
    }
  ; { id = 24
    ; header = "API Documentation"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "8"
    ; limit = "12"
    ; reviewer = "Raj Patel"
    }
  ; { id = 25
    ; header = "User Interface Mockups"
    ; type_ = "Visual"
    ; status = "In Process"
    ; target = "19"
    ; limit = "25"
    ; reviewer = "Leila Ahmadi"
    }
  ; { id = 26
    ; header = "Database Schema"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "22"
    ; limit = "20"
    ; reviewer = "Thomas Wilson"
    }
  ; { id = 27
    ; header = "Testing Methodology"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "17"
    ; limit = "14"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 28
    ; header = "Deployment Strategy"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "26"
    ; limit = "30"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 29
    ; header = "Budget Breakdown"
    ; type_ = "Financial"
    ; status = "In Process"
    ; target = "13"
    ; limit = "16"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 30
    ; header = "Market Analysis"
    ; type_ = "Research"
    ; status = "Done"
    ; target = "29"
    ; limit = "32"
    ; reviewer = "Sophia Martinez"
    }
  ; { id = 31
    ; header = "Competitor Comparison"
    ; type_ = "Research"
    ; status = "In Process"
    ; target = "21"
    ; limit = "19"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 32
    ; header = "Maintenance Plan"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "16"
    ; limit = "23"
    ; reviewer = "Alex Thompson"
    }
  ; { id = 33
    ; header = "User Personas"
    ; type_ = "Research"
    ; status = "In Process"
    ; target = "27"
    ; limit = "24"
    ; reviewer = "Nina Patel"
    }
  ; { id = 34
    ; header = "Accessibility Compliance"
    ; type_ = "Legal"
    ; status = "Done"
    ; target = "18"
    ; limit = "21"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 35
    ; header = "Performance Metrics"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "23"
    ; limit = "26"
    ; reviewer = "David Kim"
    }
  ; { id = 36
    ; header = "Disaster Recovery Plan"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "14"
    ; limit = "17"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 37
    ; header = "Third-party Integrations"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "25"
    ; limit = "28"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 38
    ; header = "User Feedback Summary"
    ; type_ = "Research"
    ; status = "Done"
    ; target = "20"
    ; limit = "15"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 39
    ; header = "Localization Strategy"
    ; type_ = "Narrative"
    ; status = "In Process"
    ; target = "12"
    ; limit = "19"
    ; reviewer = "Maria Garcia"
    }
  ; { id = 40
    ; header = "Mobile Compatibility"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "28"
    ; limit = "31"
    ; reviewer = "James Wilson"
    }
  ; { id = 41
    ; header = "Data Migration Plan"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "19"
    ; limit = "22"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 42
    ; header = "Quality Assurance Protocols"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "30"
    ; limit = "33"
    ; reviewer = "Priya Singh"
    }
  ; { id = 43
    ; header = "Stakeholder Analysis"
    ; type_ = "Research"
    ; status = "In Process"
    ; target = "11"
    ; limit = "14"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 44
    ; header = "Environmental Impact Assessment"
    ; type_ = "Research"
    ; status = "Done"
    ; target = "24"
    ; limit = "27"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 45
    ; header = "Intellectual Property Rights"
    ; type_ = "Legal"
    ; status = "In Process"
    ; target = "17"
    ; limit = "20"
    ; reviewer = "Sarah Johnson"
    }
  ; { id = 46
    ; header = "Customer Support Framework"
    ; type_ = "Narrative"
    ; status = "Done"
    ; target = "22"
    ; limit = "25"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 47
    ; header = "Version Control Strategy"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "15"
    ; limit = "18"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 48
    ; header = "Continuous Integration Pipeline"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "26"
    ; limit = "29"
    ; reviewer = "Michael Chen"
    }
  ; { id = 49
    ; header = "Regulatory Compliance"
    ; type_ = "Legal"
    ; status = "In Process"
    ; target = "13"
    ; limit = "16"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 50
    ; header = "User Authentication System"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "28"
    ; limit = "31"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 51
    ; header = "Data Analytics Framework"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "21"
    ; limit = "24"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 52
    ; header = "Cloud Infrastructure"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "16"
    ; limit = "19"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 53
    ; header = "Network Security Measures"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "29"
    ; limit = "32"
    ; reviewer = "Lisa Wong"
    }
  ; { id = 54
    ; header = "Project Timeline"
    ; type_ = "Planning"
    ; status = "Done"
    ; target = "14"
    ; limit = "17"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 55
    ; header = "Resource Allocation"
    ; type_ = "Planning"
    ; status = "In Process"
    ; target = "27"
    ; limit = "30"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 56
    ; header = "Team Structure and Roles"
    ; type_ = "Planning"
    ; status = "Done"
    ; target = "20"
    ; limit = "23"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 57
    ; header = "Communication Protocols"
    ; type_ = "Planning"
    ; status = "In Process"
    ; target = "15"
    ; limit = "18"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 58
    ; header = "Success Metrics"
    ; type_ = "Planning"
    ; status = "Done"
    ; target = "30"
    ; limit = "33"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 59
    ; header = "Internationalization Support"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "23"
    ; limit = "26"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 60
    ; header = "Backup and Recovery Procedures"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "18"
    ; limit = "21"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 61
    ; header = "Monitoring and Alerting System"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "25"
    ; limit = "28"
    ; reviewer = "Daniel Park"
    }
  ; { id = 62
    ; header = "Code Review Guidelines"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "12"
    ; limit = "15"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 63
    ; header = "Documentation Standards"
    ; type_ = "Technical content"
    ; status = "In Process"
    ; target = "27"
    ; limit = "30"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 64
    ; header = "Release Management Process"
    ; type_ = "Planning"
    ; status = "Done"
    ; target = "22"
    ; limit = "25"
    ; reviewer = "Assign reviewer"
    }
  ; { id = 65
    ; header = "Feature Prioritization Matrix"
    ; type_ = "Planning"
    ; status = "In Process"
    ; target = "19"
    ; limit = "22"
    ; reviewer = "Emma Davis"
    }
  ; { id = 66
    ; header = "Technical Debt Assessment"
    ; type_ = "Technical content"
    ; status = "Done"
    ; target = "24"
    ; limit = "27"
    ; reviewer = "Eddie Lake"
    }
  ; { id = 67
    ; header = "Capacity Planning"
    ; type_ = "Planning"
    ; status = "In Process"
    ; target = "21"
    ; limit = "24"
    ; reviewer = "Jamik Tashpulatov"
    }
  ; { id = 68
    ; header = "Service Level Agreements"
    ; type_ = "Legal"
    ; status = "Done"
    ; target = "26"
    ; limit = "29"
    ; reviewer = "Assign reviewer"
    }
  ]
;;
