Modal = require 'cozy-clearance/modal'
Photo = require '../models/photo'


module.exports = class FilesBrowser extends Modal

    id: 'files-browser-modal'
    template_content: require '../templates/browser'
    title: t 'pick from files'
    content: '<p>Loading ...</p>'

    events: -> _.extend super,
        'click img': 'toggleSelected'

    toggleSelected: (e) ->
        $(e.target).toggleClass 'selected'

    getRenderData: -> @options

    initialize: (options) ->
        super {}
        Photo.listFromFiles (err, dates) =>
            if err
                return console.log err

            console.log "WE GET HERE"

            if dates.length is 0
                @options.dates = "No photos found"
            else
                @options.dates = dates
            @options.dates = Object.keys(dates)
            (@options.dates.sort()).reverse()
            @options.photos = dates
            @$('.modal-body').html @template_content @getRenderData()

    cb: (confirmed) ->
        console.log "AND THERE", confirmed
        return unless confirmed
        @options.beforeUpload (attrs) =>
            for img in @$('.selected')
                fileid = img.id
                Photo.makeFromFile fileid, attrs, (err, photo) =>
                    return console.log err if err

                    photo.thumbsrc = "photos/thumbs/#{photo.id}.jpg"
                    @collection.add photo