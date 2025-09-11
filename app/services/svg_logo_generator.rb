class SvgLogoGenerator
  LOGO_TEMPLATES = [
    # Template 1: Sunset Over Water
    lambda do |_company_name|
      sky_color, sea_color, sun_color = [
        ["#f97316", "#38bdf8", "#fde047"],
        ["#ef4444", "#60a5fa", "#facc15"],
        ["#d946ef", "#22d3ee", "#fef08a"]
      ].sample

      <<~SVG
        <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <linearGradient id="sky" x1="0%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" stop-color="#{sky_color}" />
              <stop offset="100%" stop-color="#{sea_color}" />
            </linearGradient>
          </defs>
          <rect width="64" height="64" rx="8" fill="url(#sky)"/>
          <circle cx="32" cy="32" r="10" fill="#{sun_color}"/>
          <path d="M0 42 Q 16 32, 32 42 T 64 42" stroke="white" stroke-width="2" fill="none" opacity="0.8"/>
          <path d="M0 48 Q 16 38, 32 48 T 64 48" stroke="white" stroke-width="2" fill="none" opacity="0.6"/>
          <path d="M0 54 Q 16 44, 32 54 T 64 54" stroke="white" stroke-width="2" fill="none" opacity="0.4"/>
        </svg>
      SVG
    end,

    # Template 2: Abstract Geometric Composition
    lambda do |_company_name|
      palette = [
        ["#3b82f6", "#93c5fd", "#eff6ff"],
        ["#16a34a", "#86efac", "#f0fdf4"],
        ["#c026d3", "#f0abfc", "#fdf4ff"]
      ].sample

      <<~SVG
        <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
          <rect width="64" height="64" rx="8" fill="#{palette[2]}"/>
          <rect x="10" y="10" width="44" height="44" rx="4" fill="#{palette[1]}"/>
          <path d="M10 10 L 54 54" stroke="#{palette[0]}" stroke-width="3"/>
          <circle cx="21" cy="43" r="8" fill="#{palette[0]}" />
          <circle cx="43" cy="21" r="8" fill="white" stroke="#{palette[0]}" stroke-width="2"/>
        </svg>
      SVG
    end,

    # Template 3: Mountain Range at Night
    lambda do |_company_name|
      sky_color, moon_color, mountain_color = [
        ["#1e293b", "#f8fafc", "#334155"],
        ["#0f172a", "#e2e8f0", "#1e293b"],
        ["#172554", "#f1f5f9", "#1e3a8a"]
      ].sample

      <<~SVG
        <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
          <rect width="64" height="64" rx="8" fill="#{sky_color}"/>
          <circle cx="48" cy="16" r="6" fill="#{moon_color}"/>
          <polygon points="0,64 0,40 20,25 40,45 50,35 64,50 64,64" fill="#{mountain_color}" />
        </svg>
      SVG
    end,

    # Template 4: Wavy Abstract Pattern
    lambda do |_company_name|
      color1, color2, color3 = [
        ["#ec4899", "#fde047", "#6ee7b7"],
        ["#8b5cf6", "#34d399", "#f59e0b"],
        ["#0ea5e9", "#a78bfa", "#f472b6"]
      ].sample

      <<~SVG
        <svg width="64" height="64" viewBox="0 0 64 64" xmlns="http://www.w3.org/2000/svg">
          <rect width="64" height="64" rx="8" fill="#{color1}"/>
          <path d="M0 16 C 16 0, 48 32, 64 16" stroke="#{color2}" stroke-width="8" fill="none" />
          <path d="M0 32 C 16 16, 48 48, 64 32" stroke="#{color3}" stroke-width="8" fill="none" />
          <path d="M0 48 C 16 32, 48 64, 64 48" stroke="white" stroke-width="8" fill="none" opacity="0.5" />
        </svg>
      SVG
    end
  ].freeze

  def self.generate_random_logo(company_name)
    return nil if company_name.blank?

    template = LOGO_TEMPLATES.sample
    template.call(company_name).strip
  end
end
